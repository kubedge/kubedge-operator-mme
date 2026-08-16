# Tasks — container-run-smoke

- [ ] DECISION: pick the local cluster for K8S01 (kind / minikube / colima+k3s).
- [ ] `make generate` → apply the generated CRDs to the cluster; confirm they register.
- [ ] Build a consumer operator image against this base (buildx arm64) and deploy it.
- [ ] Apply a sample CR; confirm the operator pod starts and sets `status.actualState`.
- [ ] `make undeploy`; confirm clean teardown (ownerref GC removes rendered resources).
