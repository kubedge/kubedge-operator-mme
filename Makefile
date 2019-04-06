
# Image URL to use all building/pushing image targets
COMPONENT        ?= kubedge-mme-operator
VERSION_V1       ?= 0.1.0
DHUBREPO_DEV     ?= kubedge1/${COMPONENT}-dev
DHUBREPO_AMD64   ?= kubedge1/${COMPONENT}-amd64
DHUBREPO_ARM32V7 ?= kubedge1/${COMPONENT}-arm32v7
DHUBREPO_ARM64V8 ?= kubedge1/${COMPONENT}-arm64v8
DOCKER_NAMESPACE ?= kubedge1
IMG_DEV          ?= ${DHUBREPO_DEV}:v${VERSION_V1}
IMG_AMD64        ?= ${DHUBREPO_AMD64}:v${VERSION_V1}
IMG_ARM32V7      ?= ${DHUBREPO_ARM32V7}:v${VERSION_V1}
IMG_ARM64V8      ?= ${DHUBREPO_ARM64V8}:v${VERSION_V1}

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
	echo -e 'export PATH=$${PATH}:/usr/local/kubebuilder/bin'
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
generate: setup
	go run vendor/sigs.k8s.io/controller-tools/cmd/controller-gen/main.go crd --output-dir ./chart/templates/ --domain kubedge.cloud
	go run vendor/k8s.io/code-generator/cmd/deepcopy-gen/main.go --input-dirs github.com/kubedge/kubedge-operator-mme/pkg/apis/kubedgeoperators/v1alpha1 -O zz_generated.deepcopy --bounding-dirs github.com/kubedge/kubedge-operator-mme/pkg/apis

# Build the docker image
docker-build: fmt vet-v1 docker-build-dev docker-build-amd64 docker-build-arm32v7 docker-build-arm64v8

docker-build-dev:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/kubedge-mme-operator -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./cmd/...
	docker build . -f build/Dockerfile -t ${IMG_DEV}
	docker tag ${IMG_DEV} ${DHUBREPO_DEV}:latest

docker-build-amd64:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/kubedge-mme-operator -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./cmd/...
	docker build . -f build/Dockerfile.amd64 -t ${IMG_AMD64}
	docker tag ${IMG_AMD64} ${DHUBREPO_AMD64}:latest

docker-build-arm32v7:
	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/kubedge-mme-operator -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./cmd/...
	docker build . -f build/Dockerfile.arm32v7 -t ${IMG_ARM32V7}
	docker tag ${IMG_ARM32V7} ${DHUBREPO_ARM32V7}:latest

docker-build-arm64v8:
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/kubedge-mme-operator -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./cmd/...
	docker build . -f build/Dockerfile.arm64v8 -t ${IMG_ARM64V8}
	docker tag ${IMG_ARM64V8} ${DHUBREPO_ARM64V8}:latest

# Push the docker image
docker-push: docker-push-dev docker-push-amd64 docker-push-arm32v7 docker-push-arm64v8

docker-push-dev:
	docker push ${IMG_DEV}

docker-push-amd64:
	docker push ${IMG_AMD64}

docker-push-arm32v7:
	docker push ${IMG_ARM32V7}

docker-push-arm64v8:
	docker push ${IMG_ARM64V8}

# Run against the configured Kubernetes cluster in ~/.kube/config
install: install-dev

install-dev: docker-build-dev
	helm install --name kubedge-mme-operator chart --set images.tags.operator=${IMG_DEV}

install-amd64:
	helm install --name kubedge-mme-operator chart --set images.tags.operator=${IMG_AMD64}

install-arm32v7:
	helm install --name kubedge-mme-operator chart --set images.tags.operator=${IMG_ARM32V7}

install-arm64v8:
	helm install --name kubedge-mme-operator chart --set images.tags.operator=${IMG_ARM64V8}

purge: setup
	helm delete --purge kubedge-mme-operator
