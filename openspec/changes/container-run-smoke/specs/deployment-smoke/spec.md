## ADDED Requirements

### Requirement: A deploy smoke gate proves the operator comes up in a cluster

Beyond `go build/vet/test`, there SHALL be a documented, repeatable smoke gate that
builds the image, loads it into a local cluster, installs the generated CRDs, deploys a
consumer operator built against this base, confirms the operator pod starts and a sample
CR reaches a reconciled `status.actualState`, then tears down cleanly.

#### Scenario: operator starts and reconciles a sample CR
- **WHEN** the smoke gate deploys the operator and applies a sample CR
- **THEN** the operator pod becomes Ready and sets the CR's `status.actualState`, and `make undeploy` removes the rendered resources via owner-reference GC
