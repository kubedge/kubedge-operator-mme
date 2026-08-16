# Tasks — buildx-multiarch-image

- [x] Confirm buildx + a builder are available (docker buildx ls); colima on Apple-Silicon. — created a `docker-container` builder `multiarch` (plain `docker` driver can't push a manifest list).
- [x] Add a `docker-buildx` Makefile target: `docker buildx build --platform linux/arm64 -t <image>:<tag> --push` (add `,linux/amd64` only if amd64 is still a target). — graft provides it; `PLATFORMS ?= linux/arm64,linux/amd64`.
- [x] Verify the resulting image is a manifest list (`docker buildx imagetools inspect <image>:<tag>`). — `kubedge1/kubedge-mme-operator:v0.2.0` is an OCI image index with linux/arm64 + linux/amd64.
- [x] Retire the arch-suffixed `docker-build-v1`/`docker-push-v1` targets and image names. — graft retired them (commented "RETIRED: superseded by docker-buildx").
- [x] Confirm the image runs on arm64 (Pi armv8 and/or Apple-Silicon). — operator pod ran 1/1 on the arm64 kind cluster from the pushed manifest list.
