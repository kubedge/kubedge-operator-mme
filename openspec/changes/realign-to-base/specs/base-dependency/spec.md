## ADDED Requirements

### Requirement: The operator pins the current kubedge-operator-base release

This operator SHALL depend on `github.com/kubedge/kubedge-operator-base` at the current
published tag `v0.1.36-kubedge.20260815`, and its own `k8s.io/*` and
`sigs.k8s.io/controller-runtime` versions SHALL be consistent with that base (k8s
v0.36.x line), realigned via `go mod tidy` after the base bump.

#### Scenario: base pin and k8s stack are current
- **WHEN** `go.mod` is inspected after realign
- **THEN** it requires `kubedge-operator-base v0.1.36-kubedge.20260815` and `k8s.io/api` on the v0.36 line, and `go build ./...` is green
