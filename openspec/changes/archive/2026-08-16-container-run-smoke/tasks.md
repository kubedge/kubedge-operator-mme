# Tasks — container-run-smoke

- [x] DECISION: pick the local cluster for K8S01 (kind / minikube / colima+k3s). — used the existing `kind-ecds` kind cluster.
- [x] `make generate` → apply the generated CRDs to the cluster; confirm they register. — `mmesims` CRD installed via `chart/crds/` (Helm API-install); registered and served.
- [x] Build a consumer operator image against this base (buildx arm64) and deploy it. — `kubedge1/kubedge-mme-operator:v0.2.0` (multi-arch) built+pushed; helm-installed; pod 1/1 Running on arm64.
- [x] Apply a sample CR; confirm the operator pod starts and sets `status.actualState`. — applied `examples/mmesim.yaml`; MMESim `STATE=deployed TARGET=deployed SATISFIED=true`; operator rendered 4 StatefulSets (fsb/gpb/lc/ncb, all 1/1) + 4 Services.
- [x] `make undeploy`; confirm clean teardown (ownerref GC removes rendered resources). — `helm uninstall` + CR delete + CRD delete; resources removed.
