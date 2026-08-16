# container-packaging Specification

## Purpose
TBD - created by archiving change buildx-multiarch-image. Update Purpose after archive.
## Requirements
### Requirement: The operator image is a single multi-arch image built with buildx

The build SHALL produce one image under a single `name:tag` covering the target
architectures (at least `linux/arm64`) via `docker buildx`, replacing the legacy
single-arch `docker-build-v1`/`docker-push-v1` flow and dropping arch suffixes from the
image name. The runtime/registry SHALL select the architecture from the manifest list.

#### Scenario: one tag serves all target arches
- **WHEN** `docker buildx imagetools inspect <image>:<tag>` is run after a build
- **THEN** the tag resolves to a manifest list including `linux/arm64`

