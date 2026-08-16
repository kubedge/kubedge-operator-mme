#!/usr/bin/env bash
# smoke.sh — local container run-smoke gate for kubedge-mme-operator.
#
# Proves the operator actually comes up and reconciles, not just that it compiles:
#   build image -> load into a kind cluster -> helm install -> apply a sample CR ->
#   assert the MMESim reports SATISFIED and every component StatefulSet is Ready.
#
# Cluster decision (K8S01): kind on top of colima's docker. Rationale — colima already
# provides the docker daemon the buildx image build needs, and `kind load docker-image`
# moves that image straight into the node's containerd (k3s/containerd can't otherwise
# see colima-docker images). minikube/colima+k3s were rejected: extra image-plumbing.
#
# Usage:
#   bin/smoke.sh up       # create/reuse cluster, build+load image, deploy, apply CR, assert
#   bin/smoke.sh down     # delete the CR + helm release (leaves the cluster)
#   bin/smoke.sh nuke     # down + delete the kind cluster
#   bin/smoke.sh          # up, assert, then down (full cycle; the CI-style gate)
set -euo pipefail

CLUSTER="${CLUSTER:-mme}"
NAMESPACE="${NAMESPACE:-default}"
RELEASE="${RELEASE:-kubedge-mme-operator}"
VERSION="${VERSION:-0.2.0}"
IMG="${IMG:-kubedge1/kubedge-mme-operator:v${VERSION}}"
NODE="${CLUSTER}-control-plane"
COMPONENTS=(businesslogic enrichment frontend loadbalancer platform)

# colima's docker socket, so kind and buildx talk to the same daemon.
COLIMA_SOCK="${HOME}/.config/colima/default/docker.sock"
[ -S "$COLIMA_SOCK" ] && export DOCKER_HOST="unix://${COLIMA_SOCK}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

log() { printf '\n=== %s ===\n' "$*"; }
need() { command -v "$1" >/dev/null 2>&1 || {
  echo "ERROR: '$1' not found on PATH" >&2
  exit 1
}; }

ensure_cluster() {
  need kind
  need kubectl
  need helm
  if ! kind get clusters 2>/dev/null | grep -qx "$CLUSTER"; then
    log "creating kind cluster '$CLUSTER'"
    kind create cluster --name "$CLUSTER"
  else
    log "reusing kind cluster '$CLUSTER'"
  fi
  kubectl config use-context "kind-${CLUSTER}" >/dev/null
  kubectl wait --for=condition=Ready "node/${NODE}" --timeout=120s
  # The operator Deployment and the sample component pods pin czZone/ezZone nodeSelectors;
  # on a single-node cluster just satisfy both on the one node.
  kubectl label "node/${NODE}" czZone=enabled ezZone=enabled --overwrite >/dev/null
}

deploy() {
  log "building + loading image ${IMG}"
  docker buildx build --load -f build/Dockerfile -t "$IMG" .
  kind load docker-image "$IMG" --name "$CLUSTER"

  log "helm install/upgrade ${RELEASE}"
  # pull_policy=Never: use the kind-loaded image, never reach a registry.
  helm upgrade --install "$RELEASE" chart \
    --set images.tags.operator="$IMG" \
    --set images.pull_policy=Never \
    --namespace "$NAMESPACE"

  kubectl wait --for=condition=Ready pod \
    -l "name=${RELEASE}" -n "$NAMESPACE" --timeout=120s
}

apply_cr_and_assert() {
  log "applying examples/mme.yaml"
  kubectl apply -f examples/mme.yaml -n "$NAMESPACE"

  log "waiting for MMESim to report satisfied"
  local satisfied=""
  for _ in $(seq 1 30); do
    satisfied="$(kubectl get mmesim kubedge-mme-cluster -n "$NAMESPACE" \
      -o jsonpath='{.status.satisfied}' 2>/dev/null || true)"
    [ "$satisfied" = "true" ] && break
    sleep 2
  done
  if [ "$satisfied" != "true" ]; then
    echo "FAIL: MMESim not satisfied after wait (satisfied=${satisfied:-<none>})" >&2
    kubectl get mmesim kubedge-mme-cluster -n "$NAMESPACE" -o yaml >&2 || true
    exit 1
  fi

  log "asserting component StatefulSets are Ready"
  local c
  for c in "${COMPONENTS[@]}"; do
    kubectl rollout status "statefulset/${c}" -n "$NAMESPACE" --timeout=120s
  done

  log "SMOKE PASS — operator reconciled MMESim; all components Ready"
  kubectl get mmesim,statefulset -n "$NAMESPACE"
}

teardown() {
  log "removing sample CR + helm release"
  kubectl delete -f examples/mme.yaml -n "$NAMESPACE" --ignore-not-found --timeout=120s || true
  helm uninstall "$RELEASE" --namespace "$NAMESPACE" 2>/dev/null || true
}

case "${1:-cycle}" in
  up)
    ensure_cluster
    deploy
    apply_cr_and_assert
    ;;
  down) teardown ;;
  nuke)
    teardown
    kind delete cluster --name "$CLUSTER"
    ;;
  cycle)
    ensure_cluster
    deploy
    apply_cr_and_assert
    teardown
    ;;
  *)
    echo "usage: $0 [up|down|nuke|cycle]" >&2
    exit 2
    ;;
esac
