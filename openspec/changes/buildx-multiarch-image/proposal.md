# Build a single multi-arch image with buildx

## Why

The current `build/Dockerfile` is single-arch `linux/amd64` (alpine), driven by
`docker-build-v1`. But the real targets are arm64 (Raspberry Pi armv8 + Apple-Silicon
dev), and the legacy scheme baked the arch into the image name, which historically forced
per-arch Helm chart branches. `docker buildx` produces one multi-arch image under a
single name:tag and the runtime resolves the arch — collapsing all of that.

## What changes

- Replace the single-arch `docker-build-v1`/`docker-push-v1` flow with a `docker buildx
  build --platform linux/arm64[,linux/amd64] -t <image>:<tag> --push` target.
- Drop arch suffixes from the image name.
- On Apple-Silicon, arm64 is native; amd64 (if kept) builds via emulation (colima/qemu).

## Non-goals

- The Helm chart consolidation (kill per-arch branches) — that lives in the helm/util
  repos as its own change; this one only makes the image multi-arch.

## Impact

Fleet-wide (all operators + sims). Prerequisite for the chart consolidation.
