# Tasks — realign-to-base

- [x] `go get github.com/kubedge/kubedge-operator-base@v0.1.36-kubedge.20260815`
- [x] `go mod tidy` (confirm k8s.io/* → v0.36.x, controller-runtime → v0.24.x, go → 1.26)
- [x] `go build ./...` → fix controller-runtime Watch API + printf-vet breakages
- [x] `go vet ./... && go test ./... -race` green
- [x] `golangci-lint run --max-same-issues 0 --max-issues-per-linter 0 ./...` (record; lint cleanup can follow) — 3 pre-existing issues recorded (deprecated GetEventRecorderFor, redundant fmt.Sprintf in test, unused `log` var); non-blocking
- [x] Confirm the operator still builds its binary (`go build ./cmd/...` or the Makefile build path)
