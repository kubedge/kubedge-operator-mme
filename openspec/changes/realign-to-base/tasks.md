# Tasks — realign-to-base

- [ ] `go get github.com/kubedge/kubedge-operator-base@v0.1.36-kubedge.20260815`
- [ ] `go mod tidy` (confirm k8s.io/* → v0.36.x, controller-runtime → v0.24.x, go → 1.26)
- [ ] `go build ./...` → fix controller-runtime Watch API + printf-vet breakages
- [ ] `go vet ./... && go test ./... -race` green
- [ ] `golangci-lint run --max-same-issues 0 --max-issues-per-linter 0 ./...` (record; lint cleanup can follow)
- [ ] Confirm the operator still builds its binary (`go build ./cmd/...` or the Makefile build path)
