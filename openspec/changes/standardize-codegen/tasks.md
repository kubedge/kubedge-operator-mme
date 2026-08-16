# Tasks — standardize-codegen

- [ ] `go install sigs.k8s.io/controller-tools/cmd/controller-gen@v0.21.0`; confirm `controller-gen --version`.
- [ ] Edit the `generate` target: remove `crd:trivialVersions=true`.
- [ ] Fix `setup`: drop the hard-coded `/usr/local/kubebuilder/bin` PATH (use the brew-prefix tool).
- [ ] `make generate`; confirm CRDs regenerate under `chart/templates/` and deepcopy under `pkg/apis/.../v1alpha1`.
- [ ] `go build ./...` green after regeneration; review the CRD yaml diff.
