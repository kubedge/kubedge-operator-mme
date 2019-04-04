// Copyright 2019 The Kubedge Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package mmesim

import (
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/manager"

	av1 "github.com/kubedge/kubedge-operator-base/pkg/apis/kubedgeoperators/v1alpha1"
	bmgr "github.com/kubedge/kubedge-operator-base/pkg/kubedgemanager"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

type managerFactory struct {
	kubeClient client.Client
}

// Simple function to init the renderFiles passed to the helm renderer
func initRenderFiles(stage av1.OslcPhase) []string {
	renderFiles := make([]string, 0)
	return renderFiles
}

// Simple function to init the renderValues passed to the helm renderer
func initRenderValues(stage av1.OslcPhase) map[string]interface{} {
	oslcValues := map[string]interface{}{}
	oslcValues["stage"] = stage.String()
	renderValues := map[string]interface{}{}
	renderValues["oslc"] = oslcValues
	return renderValues
}

// NewManagerFactory returns a new factory.
func NewManagerFactory(mgr manager.Manager) bmgr.KubedgeResourceManagerFactory {
	return &managerFactory{kubeClient: mgr.GetClient()}
}

// NewArpscanManager returns a new manager capable of controlling Arpscan phase of the service lifecyle
func (f managerFactory) NewArpscanManager(r *av1.Arpscan) bmgr.KubedgeResourceManager {
	return nil
}

// NewECDSClusterManager returns a new manager capable of controlling ECDSCluster phase of the service lifecyle
func (f managerFactory) NewECDSClusterManager(r *av1.ECDSCluster) bmgr.KubedgeResourceManager {
	return nil
}

// NewMMESimManager returns a new manager capable of controlling MMESim phase of the service lifecyle
func (f managerFactory) NewMMESimManager(r *av1.MMESim) bmgr.KubedgeResourceManager {
	controllerRef := metav1.NewControllerRef(r, r.GroupVersionKind())
	ownerRefs := []metav1.OwnerReference{
		*controllerRef,
	}

	renderFiles := initRenderFiles(av1.PhaseRollback)
	renderValues := initRenderValues(av1.PhaseRollback)

	return &rollbackmanager{
		KubedgeBaseManager: bmgr.KubedgeBaseManager{
			KubeClient:     f.kubeClient,
			Renderer:       bmgr.NewKubedgeBaseRenderer(ownerRefs, "mmesim", renderFiles, renderValues),
			Source:         r.Spec.Source,
			PhaseName:      r.GetName(),
			PhaseNamespace: r.GetNamespace()},

		spec:   r.Spec,
		status: &r.Status,
	}
}
