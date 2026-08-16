# Uplift test coverage

## Why

The repo has a single test file (`pkg/kubedgemanager/ownerref_renderer_test.go`); 9
packages have none. The historical bar was "compile + start", so correctness was never
locked in. As the fleet modernizes, the highest-leverage logic (the shared engine and the
API contract) should get tests so consumers can rely on it.

## What changes

- Add unit tests for the highest-value shared logic first: the manager factory /
  renderer (owner-ref stamping, lifecycle-state mapping) and the conditions package
  (Get/Has/IsTrue/IsFalse).
- Wire `go test ./... -race -coverprofile` into the local loop and the class-M CI.

## Non-goals

- 100% coverage. Target the shared contract paths consumers depend on, not exhaustive coverage.

## Impact

Base is imported by every operator, so tests here protect the whole family. Template for
the fleet (each consumer adds tests for its own reconcile).
