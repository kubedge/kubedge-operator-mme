## ADDED Requirements

### Requirement: `make generate` regenerates CRDs and deepcopy with a modern controller-gen

`make generate` SHALL run against a pinned modern controller-gen (v0.21.0, installed via
`go install sigs.k8s.io/controller-tools/cmd/controller-gen@v0.21.0`), SHALL NOT pass the
removed `crd:trivialVersions=true` flag, and SHALL NOT depend on a hard-coded
`/usr/local/kubebuilder/bin` PATH. It regenerates the CRD manifests under
`chart/templates/` and deepcopy under `pkg/apis/.../v1alpha1`.

#### Scenario: generate succeeds on a modern toolchain
- **WHEN** `make generate` runs with controller-gen v0.21.0 on PATH
- **THEN** it completes without the `trivialVersions` error and regenerates CRDs + deepcopy, and `go build ./...` stays green
