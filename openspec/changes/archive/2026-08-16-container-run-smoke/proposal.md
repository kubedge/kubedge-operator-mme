# Add a container + run smoke gate

## Why

`go build/vet/test` proves the code compiles; it does not prove the operator image comes
up in a cluster. Per the domain, the real bar is build image → load into a cluster →
apply CRDs + deploy → confirm it starts. Base is a library (no standalone image to run on
its own), so its "run" gate is: its generated CRDs install and a consumer operator built
against it deploys and reaches Ready.

## What changes

- Define a local cluster story for K8S01 (kind / minikube / colima+k3s) — decision needed.
- Document/automate: `make generate` → install CRDs → deploy a consumer operator built
  against this base → confirm the operator pod starts and the sample CR reconciles →
  `make undeploy`.

## Non-goals

- Full e2e behavior tests; this is a smoke gate (does it come up), not a test suite.

## Impact

Establishes the run gate the whole fleet reuses. Blocked on the local-cluster decision.
