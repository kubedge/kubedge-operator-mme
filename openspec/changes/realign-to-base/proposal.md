# Realign to the current kubedge-operator-base

## Why

This operator pins `kubedge-operator-base v0.1.29-kubedge.20240602` and sits on k8s
v0.29.5 / controller-runtime v0.17.3 / go 1.22. The base is now published at
`v0.1.36-kubedge.20260815` (k8s v0.36.3 / controller-runtime v0.24.1 / go 1.26). A
consumer must realign UP to the base, which also drags its own k8s stack forward — the
base and its consumers are versioned together.

## What Changes

- `go get github.com/kubedge/kubedge-operator-base@v0.1.36-kubedge.20260815` then
  `go mod tidy` (this also raises `k8s.io/*`, controller-runtime, and the `go` directive).
- Fix the build breakages the base bump surfaces (same families base hit):
  controller-runtime generic Watch API (`c.Watch(source.Kind(cache, obj, handler, preds...))`,
  pin `client.Object(&u)` where needed); `go vet` non-constant printf (wrap `Fn(..., "%s", msg)`).
- Keep `go build/vet/test ./...` green.

## Capabilities

### Modified Capabilities
- base-dependency: the pinned base version and the k8s stack it transitively sets.
