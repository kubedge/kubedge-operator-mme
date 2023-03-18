# kubedge-operator-mme

Operator to deploy KUBEDGE MME Simulator

## Notes


## Getting started

### Install operator using helm

```bash
$ make install-amd64
```

```code
helm install kubedge-mme-operator chart --set images.tags.operator=kubedge1/kubedge-mme-operator-amd64:v0.1.0,images.pull_policy=Always --namespace default
NAME: kubedge-mme-operator
LAST DEPLOYED: Sat Mar 18 19:52:48 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

```bash
$ kubectl get all -A
```

```code
NAMESPACE          NAME                                           READY   STATUS                   RESTARTS       AGE
calico-apiserver   pod/calico-apiserver-6d6df8c6b5-4ksj7          0/1     ContainerStatusUnknown   1 (19d ago)    19d
calico-apiserver   pod/calico-apiserver-6d6df8c6b5-9px6v          1/1     Running                  15 (67m ago)   19d
calico-apiserver   pod/calico-apiserver-6d6df8c6b5-h7nzq          1/1     Running                  12 (67m ago)   19d
calico-system      pod/calico-kube-controllers-6b7b9c649d-92zrb   1/1     Running                  14 (67m ago)   19d
calico-system      pod/calico-node-s5648                          1/1     Running                  14 (67m ago)   19d
calico-system      pod/calico-typha-7c747fc89b-4xnrf              1/1     Running                  26 (66m ago)   19d
calico-system      pod/csi-node-driver-zgdwc                      2/2     Running                  28 (67m ago)   19d
default            pod/kubedge-mme-operator-897677f99-njjgd       1/1     Running                  0              69s
kube-system        pod/coredns-787d4945fb-cm7x9                   1/1     Running                  14 (67m ago)   20d
kube-system        pod/coredns-787d4945fb-mhs4b                   1/1     Running                  14 (67m ago)   20d
kube-system        pod/etcd-node                                  1/1     Running                  14 (67m ago)   20d
kube-system        pod/kube-apiserver-node                        1/1     Running                  14 (67m ago)   20d
kube-system        pod/kube-controller-manager-node               1/1     Running                  19 (67m ago)   20d
kube-system        pod/kube-proxy-hl6z5                           1/1     Running                  14 (67m ago)   20d
kube-system        pod/kube-scheduler-node                        1/1     Running                  16 (67m ago)   20d
tigera-operator    pod/tigera-operator-54b47459dd-m4gl4           1/1     Running                  30 (67m ago)   19d

NAMESPACE          NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
calico-apiserver   service/calico-api                        ClusterIP   10.108.208.171   <none>        443/TCP                  19d
calico-system      service/calico-kube-controllers-metrics   ClusterIP   None             <none>        9094/TCP                 19d
calico-system      service/calico-typha                      ClusterIP   10.108.82.253    <none>        5473/TCP                 19d
default            service/kubernetes                        ClusterIP   10.96.0.1        <none>        443/TCP                  20d
kube-system        service/kube-dns                          ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   20d

NAMESPACE       NAME                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
calico-system   daemonset.apps/calico-node       1         1         1       1            1           kubernetes.io/os=linux   19d
calico-system   daemonset.apps/csi-node-driver   1         1         1       1            1           kubernetes.io/os=linux   19d
kube-system     daemonset.apps/kube-proxy        1         1         1       1            1           kubernetes.io/os=linux   20d

NAMESPACE          NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
calico-apiserver   deployment.apps/calico-apiserver          2/2     2            2           19d
calico-system      deployment.apps/calico-kube-controllers   1/1     1            1           19d
calico-system      deployment.apps/calico-typha              1/1     1            1           19d
default            deployment.apps/kubedge-mme-operator      1/1     1            1           69s
kube-system        deployment.apps/coredns                   2/2     2            2           20d
tigera-operator    deployment.apps/tigera-operator           1/1     1            1           19d

NAMESPACE          NAME                                                 DESIRED   CURRENT   READY   AGE
calico-apiserver   replicaset.apps/calico-apiserver-6d6df8c6b5          2         2         2       19d
calico-system      replicaset.apps/calico-kube-controllers-6b7b9c649d   1         1         1       19d
calico-system      replicaset.apps/calico-typha-7c747fc89b              1         1         1       19d
default            replicaset.apps/kubedge-mme-operator-897677f99       1         1         1       69s
kube-system        replicaset.apps/coredns-787d4945fb                   2         2         2       20d
tigera-operator    replicaset.apps/tigera-operator-54b47459dd           1         1         1       19d
```

### Deploy the MME simulator

```bash
$ kubectl apply -f examples/mmesim-amd64.yaml
mmesim.kubedgeoperators.kubedge.cloud/kubedge-mmesim-cluster created
```

```bash
$ kubectl get all -A
```

```code
NAMESPACE          NAME                                           READY   STATUS                   RESTARTS       AGE
calico-apiserver   pod/calico-apiserver-6d6df8c6b5-4ksj7          0/1     ContainerStatusUnknown   1 (19d ago)    19d
calico-apiserver   pod/calico-apiserver-6d6df8c6b5-9px6v          1/1     Running                  15 (70m ago)   19d
calico-apiserver   pod/calico-apiserver-6d6df8c6b5-h7nzq          1/1     Running                  12 (70m ago)   19d
calico-system      pod/calico-kube-controllers-6b7b9c649d-92zrb   1/1     Running                  14 (70m ago)   19d
calico-system      pod/calico-node-s5648                          1/1     Running                  14 (70m ago)   19d
calico-system      pod/calico-typha-7c747fc89b-4xnrf              1/1     Running                  26 (68m ago)   19d
calico-system      pod/csi-node-driver-zgdwc                      2/2     Running                  28 (70m ago)   19d
default            pod/fsb-0                                      1/1     Running                  0              88s
default            pod/gpb-0                                      1/1     Running                  0              88s
default            pod/kubedge-mme-operator-897677f99-njjgd       1/1     Running                  0              3m51s
default            pod/lc-0                                       1/1     Running                  0              88s
default            pod/ncb-0                                      1/1     Running                  0              88s
kube-system        pod/coredns-787d4945fb-cm7x9                   1/1     Running                  14 (70m ago)   20d
kube-system        pod/coredns-787d4945fb-mhs4b                   1/1     Running                  14 (70m ago)   20d
kube-system        pod/etcd-node                                  1/1     Running                  14 (70m ago)   20d
kube-system        pod/kube-apiserver-node                        1/1     Running                  14 (70m ago)   20d
kube-system        pod/kube-controller-manager-node               1/1     Running                  19 (70m ago)   20d
kube-system        pod/kube-proxy-hl6z5                           1/1     Running                  14 (70m ago)   20d
kube-system        pod/kube-scheduler-node                        1/1     Running                  16 (70m ago)   20d
tigera-operator    pod/tigera-operator-54b47459dd-m4gl4           1/1     Running                  30 (70m ago)   19d

NAMESPACE          NAME                                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
calico-apiserver   service/calico-api                        ClusterIP   10.108.208.171   <none>        443/TCP                  19d
calico-system      service/calico-kube-controllers-metrics   ClusterIP   None             <none>        9094/TCP                 19d
calico-system      service/calico-typha                      ClusterIP   10.108.82.253    <none>        5473/TCP                 19d
default            service/fsb                               ClusterIP   None             <none>        <none>                   88s
default            service/gpb                               ClusterIP   None             <none>        <none>                   88s
default            service/kubernetes                        ClusterIP   10.96.0.1        <none>        443/TCP                  20d
default            service/lc                                ClusterIP   None             <none>        <none>                   88s
default            service/ncb                               ClusterIP   None             <none>        <none>                   88s
kube-system        service/kube-dns                          ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   20d

NAMESPACE       NAME                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
calico-system   daemonset.apps/calico-node       1         1         1       1            1           kubernetes.io/os=linux   19d
calico-system   daemonset.apps/csi-node-driver   1         1         1       1            1           kubernetes.io/os=linux   19d
kube-system     daemonset.apps/kube-proxy        1         1         1       1            1           kubernetes.io/os=linux   20d

NAMESPACE          NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
calico-apiserver   deployment.apps/calico-apiserver          2/2     2            2           19d
calico-system      deployment.apps/calico-kube-controllers   1/1     1            1           19d
calico-system      deployment.apps/calico-typha              1/1     1            1           19d
default            deployment.apps/kubedge-mme-operator      1/1     1            1           3m51s
kube-system        deployment.apps/coredns                   2/2     2            2           20d
tigera-operator    deployment.apps/tigera-operator           1/1     1            1           19d

NAMESPACE          NAME                                                 DESIRED   CURRENT   READY   AGE
calico-apiserver   replicaset.apps/calico-apiserver-6d6df8c6b5          2         2         2       19d
calico-system      replicaset.apps/calico-kube-controllers-6b7b9c649d   1         1         1       19d
calico-system      replicaset.apps/calico-typha-7c747fc89b              1         1         1       19d
default            replicaset.apps/kubedge-mme-operator-897677f99       1         1         1       3m51s
kube-system        replicaset.apps/coredns-787d4945fb                   2         2         2       20d
tigera-operator    replicaset.apps/tigera-operator-54b47459dd           1         1         1       19d

NAMESPACE   NAME                   READY   AGE
default     statefulset.apps/fsb   1/1     88s
default     statefulset.apps/gpb   1/1     88s
default     statefulset.apps/lc    1/1     88s
default     statefulset.apps/ncb   1/1     88s
```
