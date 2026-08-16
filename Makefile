
# Image URL to use all building/pushing image targets
COMPONENT        ?= kubedge-mme-operator
VERSION          ?= 0.2.0
DHUBREPO         ?= kubedge1/${COMPONENT}
DOCKER_NAMESPACE ?= kubedge1
IMG              ?= ${DHUBREPO}:v${VERSION}
K8S_NAMESPACE    ?= default

# Target platforms for the single multi-arch image. arm64 primary (Apple-Silicon +
# Raspberry Pi armv8); amd64 kept for x86 clusters. Override:
#   make docker-buildx PLATFORMS=linux/arm64
PLATFORMS        ?= linux/arm64,linux/amd64

# RETIRED: superseded by docker-buildx (multi-arch). The per-arch image variants below
# built four separate arch-suffixed images by copying a prebuilt binary into each — the
# arm images were actually amd64 binaries. Preserved (commented) for discoverability.
# VERSION_V1       ?= 0.2.0
# DHUBREPO_DEV     ?= kubedge1/${COMPONENT}-dev
# DHUBREPO_AMD64   ?= kubedge1/${COMPONENT}-amd64
# DHUBREPO_ARM32V7 ?= kubedge1/${COMPONENT}-arm32v7
# DHUBREPO_ARM64V8 ?= kubedge1/${COMPONENT}-arm64v8
# IMG_DEV          ?= ${DHUBREPO_DEV}:v${VERSION_V1}
# IMG_AMD64        ?= ${DHUBREPO_AMD64}:v${VERSION_V1}
# IMG_ARM32V7      ?= ${DHUBREPO_ARM32V7}:v${VERSION_V1}
# IMG_ARM64V8      ?= ${DHUBREPO_ARM64V8}:v${VERSION_V1}

# CONTAINER_TOOL defines the container tool to be used for building images.
# Be aware that the target commands are only tested with Docker which is
# scaffolded by default. However, you might want to replace it to use other
# tools. (i.e. podman)
CONTAINER_TOOL ?= docker

# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec


all: docker-build

setup:
ifndef GOPATH
	$(error GOPATH not defined, please define GOPATH. Run "go help gopath" to learn more about GOPATH)
endif
	# dep ensure

clean:
	rm -fr vendor
	rm -fr cover.out
	rm -fr build/_output
	rm -fr config/crds
	rm -fr go.sum

# Run tests
unittest: setup fmt vet-v1
	echo "sudo systemctl stop kubelet"
	echo -e 'docker stop $$(docker ps -qa)'
	mkdir -p config/crds
	cp chart/templates/*v1alpha1* config/crds/
	go test ./pkg/... ./cmd/... -coverprofile cover.out

# Run go fmt against code
fmt: setup
	go fmt ./pkg/... ./cmd/...

# Run go vet against code
vet-v1: fmt
	go vet -composites=false -tags=v1 ./pkg/... ./cmd/...

# Generate code
#
# MMESim's Go type is defined in kubedge-operator-base, not here — this repo is
# a consumer of that shared API. So the CRD is regenerated from the *pinned* base
# module (it tracks whatever version go.mod resolves) rather than a local pkg/apis,
# and there is no deepcopy (controller-gen object) step: base owns the DeepCopy code.
# controller-gen is provided by `go install sigs.k8s.io/controller-tools/cmd/controller-gen@v0.21.0`.
CONTROLLER_GEN ?= controller-gen
BASE_APIS := $(shell go list -m -f '{{.Dir}}' github.com/kubedge/kubedge-operator-base)/pkg/apis/kubedgeoperators/...

generate: generate-manifests

generate-manifests:
	# CRDs go in chart/crds/ (not chart/templates/): Helm installs crds/ via the API
	# and does NOT store them in the release Secret. The mmesims CRD embeds five
	# full PodTemplateSpec schemas (~3.2MB) and would blow Helm's 1MB release-Secret
	# limit if templated; crds/ sidesteps that.
	mkdir -p chart/crds/
	rm -rf build/_crds && mkdir -p build/_crds
	GO111MODULE=on $(CONTROLLER_GEN) crd:generateEmbeddedObjectMeta=true paths=$(BASE_APIS) output:crd:dir=./build/_crds output:none
	cp build/_crds/kubedgeoperators.kubedge.cloud_mmesims.yaml chart/crds/
	rm -rf build/_crds

# Build and push a single multi-arch image (manifest list). The binary is compiled per
# TARGETOS/TARGETARCH inside build/Dockerfile, so one command covers every platform.
# Needs a live buildx builder — on Apple-Silicon run `colima start` first.
.PHONY: docker-buildx
docker-buildx: vet-v1
	docker buildx build --platform ${PLATFORMS} -f build/Dockerfile -t ${IMG} -t ${DHUBREPO}:latest --push .

# Local single-arch image for dev (loads into the local docker; no push).
.PHONY: docker-build
docker-build: vet-v1
	docker buildx build --load -f build/Dockerfile -t ${IMG} .

# Push is folded into docker-buildx (--push); kept as an alias for muscle memory.
.PHONY: docker-push
docker-push: docker-buildx

# RETIRED: superseded by docker-buildx (multi-arch). The legacy per-arch build/push
# machinery pre-compiled a binary per arch and copied it into an arch-specific Dockerfile
# (build/Dockerfile.{dev,amd64,arm32v7,arm64v8}, now under build/legacy/). Preserved
# (commented) for discoverability; do not resurrect — docker-buildx is the sole path.
# docker-build: fmt vet-v1 docker-build-dev docker-build-amd64 docker-build-arm32v7 docker-build-arm64v8
#
# docker-build-dev:
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/kubedge-mme-operator -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./cmd/...
# 	docker buildx build --platform=linux/amd64 -f build/Dockerfile.dev -t ${IMG_DEV} .
# 	docker tag ${IMG_DEV} ${DHUBREPO_DEV}:latest
#
# docker-build-amd64:
# 	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/kubedge-mme-operator -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./cmd/...
# 	docker buildx build --platform=linux/amd64 -f build/Dockerfile.amd64 -t ${IMG_AMD64} .
# 	docker tag ${IMG_AMD64} ${DHUBREPO_AMD64}:latest
#
# docker-build-arm32v7:
# 	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/kubedge-mme-operator -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./cmd/...
# 	docker buildx build --platform=linux/arm/v7 -f build/Dockerfile.arm32v7 -t ${IMG_ARM32V7} .
# 	docker tag ${IMG_ARM32V7} ${DHUBREPO_ARM32V7}:latest
#
# docker-build-arm64v8:
# 	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/kubedge-mme-operator -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./cmd/...
# 	docker buildx build --platform=linux/arm64 -f build/Dockerfile.arm64v8 -t ${IMG_ARM64V8} .
# 	docker tag ${IMG_ARM64V8} ${DHUBREPO_ARM64V8}:latest
#
# docker-push: docker-push-dev docker-push-amd64 docker-push-arm32v7 docker-push-arm64v8
# docker-push-dev:
# 	docker push ${IMG_DEV}
# docker-push-amd64:
# 	docker push ${IMG_AMD64}
# docker-push-arm32v7:
# 	docker push ${IMG_ARM32V7}
# docker-push-arm64v8:
# 	docker push ${IMG_ARM64V8}

# Local container run-smoke gate: build -> load into kind -> deploy -> apply a sample CR
# -> assert the MMESim reconciles and every component is Ready -> tear down.
# See bin/smoke.sh for the cluster decision (kind on colima) and sub-commands.
.PHONY: smoke smoke-up smoke-down
smoke:
	./bin/smoke.sh cycle
smoke-up:
	./bin/smoke.sh up
smoke-down:
	./bin/smoke.sh down

# Run against the configured Kubernetes cluster in ~/.kube/config (Helm v3).
# NOTE: this rebuilds+pushes the multi-arch image (docker-buildx --push) and needs
# registry creds. For a local/offline run use `make smoke` (kind + --load), not this.
.PHONY: install
install: docker-buildx
	helm install kubedge-mme-operator chart --set images.tags.operator=${IMG} --namespace ${K8S_NAMESPACE}

.PHONY: purge
purge:
	helm uninstall kubedge-mme-operator --namespace ${K8S_NAMESPACE}

# RETIRED: superseded by the single `install` above (Helm v3, one multi-arch image).
# install: install-dev
# install-dev: docker-build-dev
# 	helm install kubedge-mme-operator chart --set images.tags.operator=${IMG_DEV} --namespace ${K8S_NAMESPACE}
# install-amd64:
# 	helm install kubedge-mme-operator chart --set images.tags.operator=${IMG_AMD64},images.pull_policy=Always --namespace ${K8S_NAMESPACE}
# install-arm32v7:
# 	helm install kubedge-mme-operator chart --set images.tags.operator=${IMG_ARM32V7},images.pull_policy=Always --namespace ${K8S_NAMESPACE}
# install-arm64v8:
# 	helm install kubedge-mme-operator chart --set images.tags.operator=${IMG_ARM64V8},images.pull_policy=Always --namespace ${K8S_NAMESPACE}
# install-gen:
# 	helm install kubedge-mme-operator chart --set images.tags.operator=${IMG},images.pull_policy=Always --namespace ${K8S_NAMESPACE}
