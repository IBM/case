# CASE prereqs.yaml Specification
- [CASE prereqs.yaml Specification](#case-prereqsyaml-specification)
  - [Status: Beta](#status-beta)
  - [Overview](#overview)
  - [Specification](#specification)
    - [k8sResources](#k8sresources)
    - [k8sResourceVersions](#k8sresourceversions)
    - [k8sDistros](#k8sdistros)
      - [Distribution Resolvers](#distribution-resolvers)
    - [helm](#helm)
    - [ibmCoreServices](#ibmcoreservices)
  - [Semver Version Constraints](#semver-version-constraints)

## Status:  Beta

## Overview
The `prereqs.yaml` file describes any pre-requisites that the the CASE may require of a target cluster. This specification uses the concept of Resolver to return a boolean result from the body of the object. The resolver can then be referenced by the inventory item [Action rules](220-actions.md#prereq-rules) to construct expressions.

## Specification
The `prereqs.yaml` has the following attributes:

* `prereqs`: The roles available to the CASE inventory item actions.
  * `metadata`:  General metadata about the prereqs. See [CASE Metadata](010-case-structure.md#Specification-metadata-and-versioning) for details.
  * `prereqDefs`: The prereq resolvers.
    * `k8sResources`:  The resolver for Kubernetes resources. See [k8sResources](#k8sResources).
    * `k8sResourceVersions`: The resolver for Kubernetes resource API versions. See [k8sResourceVersions](#k8sResourceVersions).
    * `k8sDistros`: The resolver for Kubernetes distribution vendor and version. See [k8sDistros](#k8sDistros).
    * `helm`: The resolver for Helm versions.  See [helm](#helm).
    * `ibmCoreServices`  The resolver for IBM core services. See [ibmCoreServices](#ibmCoreServices).

### k8sResources
This resolver is used to identify specific instances of resources in the target Kubernetes cluster.

The `k8sResources` resource is a set of objects each with the following attributes:
* `<Resource Name>`:  A [CASE Property](010-case-structure.md#yaml-file-format) describing the resource.  (Required)
  * `metadata`:  Describes the resource.  See [CASE Metadata](010-case-structure.md#Specification-metadata-and-versioning) for details.
  * `kind`:  The kind of resource to resolve.
  * `apiGroup`:  The API Group of the resource.
  * `version`:  The version of the resource API.
  * `name`:  The name of the resource (required if not specifying a `selector` or `fieldSelector`)
  * `selector`:  The label selector (optional)
    * `matchExpressions`:  The label match expression map.  See the [Kubernetes matchExpressions documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#resources-that-support-set-based-requirements).
  * `fieldSelector`:  The field selector chain (optional)
    * `matchExpressions`:  The field match expression chain. SEe the [Kubernetes field-selectors documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/).


### k8sResourceVersions
This resolver is used to identify specific resource kinds and versions in the target Kubernetes cluster.

The `k8sResourceVersions` resource is an array of objects each with the following attributes:
* `<Resource Type Name>`:  A [CASE Property](010-case-structure.md#yaml-file-format) describing the resource type.  (Required)
  * `metadata`:  Describes the resource version.  See [CASE Metadata](010-case-structure.md#Specification-metadata-and-versioning) for details.
  * `kind`:  The kind of resource to resolve.
  * `apiGroup`:  The API Group of the resource.
  * `version`:  The version of the resource API.



### k8sDistros
This resolver is used to identify the vendor and version of the target Kubernetes cluster.  Each Distribution Resolver includes distribution-unique rules for determining the vendor of the distribution.  If the vendor is not required, use the `kubernetes` resolver.

The `k8sDistros` resource is an set objects each with the following attributes:
* `<Distribution Resolver>`:  One of a set of pre-defined kubernetes distribution resolvers
  * `metadata`:  Describes the distro.  See [CASE Metadata](010-case-structure.md#Specification-metadata-and-versioning) for details.
  * `semver`: The semantic version constraint of the Kubernetes distribution (optional).  See [semver version constraints](#semver-version-constraints).

#### Distribution Resolvers
Each Kubernetes distribution resolver is a well known name which include:

* `kubernetes` - This is the default resolver when no other distribution can be resolved.
* `ibmCloud` - IBM Cloud Kubernetes Service
* `ibmCloudPrivate` - IBM Cloud Private
* `openshift` - Red Hat OpenShift Container Platform
* `googleGKE` - Google Kubernetes Engine
* `azureAKS` - Azure Kubernetes Service
* `amazonEKS` - Amazon Elastic Container Service for Kubernetes

### helm
This resolver is used to identify the version of Helm and/or Tiller.  If this resolver is present, then a Helm client must be configured and available.

The `helm` resource has the following attributes:
* `<Helm Prereq Name>`:  A [CASE Property](010-case-structure.md#yaml-file-format) describing the Helm prerequisite.  (Required)
  * `metadata`:  Describes the Helm prereq.  See [CASE Metadata](010-case-structure.md#Specification-metadata-and-versioning) for details.
  * `helmVersion`:  The semantic version constraint of the Helm client (optional).  See [semver version constraints](#semver-version-constraints).
  * `tillerVersion`: The semantic version constraint of Tiller (optional).  See [semver version constraints](#semver-version-constraints).


### ibmCoreServices
This resolver is used to identify the availability of IBM core services in the target Kubernetes cluster.  IBM core services are available with IBM Cloud Paks.

Each IBM core service resolver key is a well known service name. The value specified here is typically the primary service of a feature that an IBM Cloud Pak or IBM certified container utilizes directly.

For a detailed list of services available IBM Cloud Private Knowledge Center.

Some common components include:

* `auth-idp`: The IBM Cloud Private Identity and Access Management service.
* `cert-manager`: The component that manages the lifecycle of certificates
* `logging`: The suite of logging services, including ElasticSearch and Kibana.
* `monitoring`: The suite of monitoring services, including Prometheus and Grafana.
* `nginx-ingress`: The default Ingress that's used on the ICP Proxy nodes.
* `service-catalog`: Implements the Open Service Broker API to provide service broker integration.
* `storage-gluster-fs`: The Gluster filesystem.

Each service-resolver includes the following fields:

* `<none>` - Reserved for future use, such as versioning.


## Semver Version Constraints
This specification utilizes the semver version constraint grammar provided by the [Masterminds/semver](https://github.com/Masterminds/semver#checking-version-constraints).  This is the same library that is used by Helm and is very flexible.

Examples:
* To support any non-patched version of Kubernetes v1 above 1.11.3:  
  * `>=1.11.3, <2`
* To support any version of Kubernetes v1 above 1.11.3, including prerereleases and versions of Kubernetes that use the hyphen characeter to identify a build version:  
  * `>=1.11.3-0, <2-0`
* To support any version of Helm v2 other than 2.11.2:  
  * `>=2.0.0, <2.11.2, >2.11.2, <3.0`
* To support Helm 3 and above:
  * `~3.x`

Example syntax (run in the [Go Playground](https://play.golang.org)):
```go
package main

import (
	"fmt"
	"github.com/Masterminds/semver"
)

func main() {
	c, err := semver.NewConstraint(">=1.11.3-0, <2.0-0")
	if err != nil {
		// Handle constraint not being parsable.
	}

	v, err := semver.NewVersion("1.11.4-alpha")
	if err != nil {
		// Handle version not being parsable.
	}
	// Check if the version meets the constraints. The a variable will be true.
	a := c.Check(v)
	fmt.Println("Check Result=", a)
}

```

