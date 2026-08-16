# Standardize CRD codegen (controller-gen)

## Why

`make generate` is broken against a modern toolchain (Note 8): it calls
`controller-gen crd ... crd:trivialVersions=true`, but `trivialVersions` was **removed**
from controller-gen, and `setup` hard-codes `/usr/local/kubebuilder/bin` on PATH — the
modern install lives at the brew prefix. So CRD/deepcopy regeneration fails on this repo.

## What Changes

- Provide controller-gen at a known-good version: `go install
  sigs.k8s.io/controller-tools/cmd/controller-gen@v0.21.0` (matches base's bump).
- Remove the removed `crd:trivialVersions=true` flag from the `generate` target.
- Drop/repair the stale `/usr/local/kubebuilder/bin` PATH assumption in `setup`.
- Re-run `make generate`; confirm CRDs (`chart/templates/`) + deepcopy
  (`pkg/apis/.../v1alpha1`) regenerate cleanly and the build stays green.

## Capabilities

### New Capabilities
- crd-generation: how this repo regenerates CRDs and deepcopy from its Go types.
