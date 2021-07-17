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

package mmesim_test

import (
	"fmt"
	"testing"

	av1 "github.com/kubedge/kubedge-operator-base/pkg/apis/kubedgeoperators/v1alpha1"
	. "github.com/kubedge/kubedge-operator-mme/pkg/mmesim"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	yaml "sigs.k8s.io/yaml"
)

func TestMMESIMRenderer(t *testing.T) {
	refs := []metav1.OwnerReference{}
	suffix := ""
	renderFiles := []string{}
	renderValues := map[string]interface{}{}
	mmesim := av1.MMESim{}

	baserenderer := NewBaseRenderer(refs, suffix, renderFiles, renderValues)
	rendered2, err := baserenderer.RenderFile("", "", "testdata/mmesim-dev.yaml")
	if err != nil {
		t.Fatalf(`error %v`, err)
	}
	if len(rendered2.Items) == 0 {
		t.Fatalf(`No items rendered`)
	}

	for _, u := range rendered2.Items {
		err1 := runtime.DefaultUnstructuredConverter.FromUnstructured(u.UnstructuredContent(), &mmesim)
		if err1 != nil {
			t.Fatalf(`error converting from Unstructured %v`, err1)
		}
	}

	mmesimrenderer := NewMMESimRenderer(refs, suffix, renderFiles, renderValues, mmesim.Spec)
	rendered, err := mmesimrenderer.RenderFile(mmesim.Name, mmesim.Namespace, "testdata/classic.yaml")
	if err != nil {
		t.Fatalf(`error %v`, err)
	}
	if len(rendered.Items) == 0 {
		t.Fatalf(`No items rendered`)
	}

	for _, toCreate := range rendered.Items {
		blob, _ := yaml.Marshal(toCreate.UnstructuredContent())
		thestr := fmt.Sprintf("%s", string(blob))
		// t.Logf("%s", thestr)
		fmt.Println("---")
		fmt.Println(thestr)
	}
}
