# Tasks — buildx-multiarch-image

- [ ] Confirm buildx + a builder are available (docker buildx ls); colima on Apple-Silicon.
- [ ] Add a `docker-buildx` Makefile target: `docker buildx build --platform linux/arm64 -t <image>:<tag> --push` (add `,linux/amd64` only if amd64 is still a target).
- [ ] Verify the resulting image is a manifest list (`docker buildx imagetools inspect <image>:<tag>`).
- [ ] Retire the arch-suffixed `docker-build-v1`/`docker-push-v1` targets and image names.
- [ ] Confirm the image runs on arm64 (Pi armv8 and/or Apple-Silicon).
