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
	"context"

	av1 "github.com/kubedge/kubedge-operator-base/pkg/apis/kubedgeoperators/v1alpha1"
	bmgr "github.com/kubedge/kubedge-operator-base/pkg/kubedgemanager"
)

type mmesimmgr struct {
	bmgr.KubedgeBaseManager

	spec   av1.MMESimSpec
	status *av1.MMESimStatus
}

// Render a chart or just a file
// func (m mmesimmgr) BaseRender(ctx context.Context) (*av1.SubResourceList, error) {
//	return m.Renderer.RenderFile(m.PhaseName, m.PhaseNamespace, m.Source.Location)
// }

// Sync retrieves from K8s the sub resources (Workflow, Job, ....) attached to this MMESim CR
func (m *mmesimmgr) Sync(ctx context.Context) error {
	return m.BaseSync(ctx)
}

// InstallResource creates K8s sub resources (Workflow, Job, ....) attached to this MMESim CR
func (m mmesimmgr) InstallResource(ctx context.Context) (*av1.SubResourceList, error) {
	return m.BaseInstallResource(ctx)
}

// InstallResource updates K8s sub resources (Workflow, Job, ....) attached to this MMESim CR
func (m mmesimmgr) UpdateResource(ctx context.Context) (*av1.SubResourceList, *av1.SubResourceList, error) {
	return m.BaseUpdateResource(ctx)
}

// ReconcileResource creates or patches resources as necessary to match this MMESim CR
func (m mmesimmgr) ReconcileResource(ctx context.Context) (*av1.SubResourceList, error) {
	return m.BaseReconcileResource(ctx)
}

// UninstallResource delete K8s sub resources (Workflow, Job, ....) attached to this MMESim CR
func (m mmesimmgr) UninstallResource(ctx context.Context) (*av1.SubResourceList, error) {
	return m.BaseUninstallResource(ctx)
}
