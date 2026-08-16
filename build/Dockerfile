# syntax=docker/dockerfile:1

# Build stage: compile the operator for the requested target platform.
# BUILDPLATFORM keeps the compiler running natively (fast) while cross-compiling to
# TARGETOS/TARGETARCH, so `docker buildx --platform linux/arm64,linux/amd64` produces a
# correct binary per arch instead of copying a single prebuilt one (the bug in the old
# per-arch Dockerfiles, which ADD'd a prebuilt amd64 binary into every arch's image).
FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS builder
ARG TARGETOS
ARG TARGETARCH
WORKDIR /workspace

# Cache module downloads before copying the full tree.
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -tags=v1 -o /out/kubedge-mme-operator ./cmd/...

# Runtime stage. FROM scratch preserves mme's proven runtime contract: the operator is
# a static (CGO-disabled) binary that only needs CA certs (to reach the API server over
# TLS) and its local MME template tree. Unlike operator-base, mme runs the binary
# directly (no user_setup/entrypoint script chain), so there is nothing to install.
FROM scratch
COPY --from=builder /out/kubedge-mme-operator /usr/local/bin/kubedge-mme-operator
COPY build/etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY build/mme-templates /opt/kubedge-operators/mme-templates
CMD ["/usr/local/bin/kubedge-mme-operator"]
