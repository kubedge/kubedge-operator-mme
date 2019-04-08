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

// ExecutionContext Kind
type ExecutionContextKind string

// Describe the possible values of an ExecutionContext
const (
	ECFSB ExecutionContextKind = "fsb"
	ECGPB ExecutionContextKind = "gpb"
	ECLC  ExecutionContextKind = "lc"
	ECNCB ExecutionContextKind = "ncb"
)

// String converts a ExecutionContextKind to a printable string
func (x ExecutionContextKind) String() string { return string(x) }
