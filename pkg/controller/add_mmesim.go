package controller

import (
	"github.com/kubedge/kubedge-operator-mme/pkg/controller/mmesim"
)

func init() {
	// AddToManagerFuncs is a list of functions to create controllers and add them to a manager.
	AddToManagerFuncs = append(AddToManagerFuncs, mmesim.AddMMESimController)
}
