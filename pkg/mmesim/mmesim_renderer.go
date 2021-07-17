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
	av1 "github.com/kubedge/kubedge-operator-base/pkg/apis/kubedgeoperators/v1alpha1"
	bmgr "github.com/kubedge/kubedge-operator-base/pkg/kubedgemanager"

	v1 "k8s.io/api/apps/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime"
)

type mmesimrenderer struct {
	base bmgr.KubedgeBaseRenderer

	spec av1.MMESimSpec
}

// Update the Unstructured read in the file using the content of the Spec.
func (o mmesimrenderer) updateStatefulSet(u *unstructured.Unstructured, k *av1.KubedgeSetSpec) {
	if k != nil {

		out := v1.StatefulSet{}
		err1 := runtime.DefaultUnstructuredConverter.FromUnstructured(u.UnstructuredContent(), &out)
		if err1 != nil {
			log.Error(err1, "error converting from Unstructured")
		}

		if k.Replicas != nil {
			out.Spec.Replicas = k.Replicas
		}

		if k.Selector != nil {
			out.Spec.Selector = k.Selector.DeepCopy()
		}

		out.Spec.Template = *(k.Template.DeepCopy())

		unst, err2 := runtime.DefaultUnstructuredConverter.ToUnstructured(&out)
		if err2 != nil {
			log.Error(err2, "error converting to Unstructured")
		}

		u.SetUnstructuredContent(unst)
	}
}

// Adds the ownerrefs to all the documents in a YAML file
func (o mmesimrenderer) RenderFile(name string, namespace string, fileName string) (*av1.SubResourceList, error) {

	// Let render the default resourceList using the ecds-template.yaml
	rendered, err := o.base.RenderFile(name, namespace, fileName)
	if err != nil {
		return rendered, err
	}

	updated := av1.NewSubResourceList(rendered.GetNamespace(), rendered.GetName())

	// Let's adapt the template using the values passed in the spec
	for _, renderedResource := range rendered.Items {
		if renderedResource.GetKind() == "StatefulSet" {
			switch renderedResource.GetName() {
			case ECFSB.String():
				o.updateStatefulSet(&renderedResource, o.spec.FSBs)
			case ECGPB.String():
				o.updateStatefulSet(&renderedResource, o.spec.GPBs)
			case ECLC.String():
				o.updateStatefulSet(&renderedResource, o.spec.LCs)
			case ECNCB.String():
				o.updateStatefulSet(&renderedResource, o.spec.NCBs)
			}
			updated.Items = append(updated.Items, renderedResource)
		} else {
			updated.Items = append(updated.Items, renderedResource)
		}
	}

	return updated, nil

}

// NewMMESimRenderer creates a new OwnerRef engine with a set of metav1.OwnerReferences to be added to assets
func NewMMESimRenderer(refs []metav1.OwnerReference, suffix string,
	renderFiles []string, renderValues map[string]interface{}, spec av1.MMESimSpec) bmgr.KubedgeResourceRenderer {
	return mmesimrenderer{
		base: bmgr.KubedgeBaseRenderer{
			Refs:         refs,
			Suffix:       suffix,
			RenderFiles:  renderFiles,
			RenderValues: renderValues,
		},
		spec: spec,
	}
}

// NewBaseRenderer creates a new OwnerRef engine with a set of metav1.OwnerReferences to be added to assets
func NewBaseRenderer(refs []metav1.OwnerReference, suffix string,
	renderFiles []string, renderValues map[string]interface{}) bmgr.KubedgeResourceRenderer {
	return bmgr.KubedgeBaseRenderer{
		Refs:         refs,
		Suffix:       suffix,
		RenderFiles:  renderFiles,
		RenderValues: renderValues,
	}
}
