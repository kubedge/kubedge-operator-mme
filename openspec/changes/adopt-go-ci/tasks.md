# Tasks — adopt-go-ci

- [x] From the meta session, run `/alemax:update-skills` so the class-M set (incl. `ci.yml`) is staged for this repo. — staged as `origin/meta-broadcast/deliver-class-m-templates-ciyml--hygiene`.
- [x] In this repo's session, run `/alemax:complete-update` to apply the update branch onto the working branch. — cherry-picked the broadcast tip onto `main` (`3b06849`).
- [x] Confirm `.github/workflows/ci.yml` present and its jobs gate on `go.mod`. — graft's fixed ci.yml (with `go` stack detection) superseded the stale broadcast copy.
- [~] Trial push the branch; confirm `go-build`/`go-vet`/`go-test`/`golangci-lint` are green. — locally green (`go build`/`go vet`/`go test -race` all pass); CI confirms on the PR push.
- [x] Confirm the rest of class-M landed: `.editorconfig`, `.gitattributes`, `.github/*`, `dependabot.yml`, `.pre-commit-config.yaml`, `bin/set-secret.sh`.
