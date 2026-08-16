# Tasks — standardize-codegen

- [x] `go install sigs.k8s.io/controller-tools/cmd/controller-gen@v0.21.0`; confirm `controller-gen --version`. — v0.21.0 installed.
- [x] Edit the `generate` target: remove `crd:trivialVersions=true`. — graft's Makefile target has no `trivialVersions` (uses `crd:generateEmbeddedObjectMeta=true` against the pinned base APIs).
- [x] Fix `setup`: drop the hard-coded `/usr/local/kubebuilder/bin` PATH (use the brew-prefix tool). — graft's Makefile resolves `controller-gen` from PATH, no hard-coded kubebuilder path.
- [x] `make generate`; confirm CRDs regenerate under `chart/crds/` and deepcopy under `pkg/apis/.../v1alpha1`. — emits `mmesims` CRD to `chart/crds/` (base owns DeepCopy; consumer has no deepcopy step). Also removed the stale duplicate CRD from `chart/templates/` that was blowing Helm's 1MB release-Secret limit.
- [x] `go build ./...` green after regeneration; review the CRD yaml diff. — build green; CRD is `mmesims.kubedgeoperators.kubedge.cloud` (kind MMESim).
