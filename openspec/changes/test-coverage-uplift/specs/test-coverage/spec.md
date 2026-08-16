## ADDED Requirements

### Requirement: The shared engine and conditions logic are unit-tested

The highest-leverage shared logic SHALL have unit tests: the manager/renderer
(owner-reference stamping and lifecycle-state mapping) and the conditions package
(`Get`/`Has`/`IsTrue`/`IsFalse`, including the absent-condition case). Tests SHALL run
under `go test ./... -race` and be covered by CI.

#### Scenario: shared contract is protected by tests
- **WHEN** `go test ./... -race` runs
- **THEN** the manager/renderer and conditions packages have passing tests (no longer 0 coverage)
