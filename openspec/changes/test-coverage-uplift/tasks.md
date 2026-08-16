# Tasks — test-coverage-uplift

- [ ] Inventory packages with no test files (`go test ./... -cover` → note 0.0% pkgs).
- [ ] Add tests for the manager/renderer: owner-ref stamping + lifecycle-state mapping.
- [ ] Add tests for the conditions package: Get/Has/IsTrue/IsFalse edge cases (absent condition).
- [ ] Add tests for the shared status/state helpers in common_types.
- [ ] Ensure `go test ./... -race` stays green; record the coverage delta.
