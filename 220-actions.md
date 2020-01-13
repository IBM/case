# CASE actions.yaml Specification
- [CASE actions.yaml Specification](#case-actionsyaml-specification)
  - [Status: Beta](#status-beta)
  - [Overview](#overview)
  - [Specification](#specification)
  - [Prereq Rules](#prereq-rules)
  - [Kubernetes Permission Rule Example](#kubernetes-permission-rule-example)

## Status:  Beta


## Overview
The `actions.yaml` includes the actions that can be applied to the inventory item and the prerequisites that are required to perform the action, including the permissions required of the current user.

## Specification
* `actions`: The actions object (required)
  * `metadata`: Information about the actions desribed in this file
  * `actionDefs`: The actions.
    * `<Action>`: A [CASE Property](100-case.md##YAML-File-Format) defining the action.  For example: `install` (required)
      * `metadata`:  Describing the action.  See [CASE Metadata](010-case-structure.md#Specification-metadata-and-versioning) for details. 
      * `roles`: One or roles required to perform this action.  See [CASE Roles](110-roles.md) for details (required)
      * `requires`: A logical expression of [CASE Prereq Resolver](120-prereqs.md) JSON Pointers that describe the prerequistes which are REQUIRED in order to install this inventory item (optional)
        * [&lt;Prereq Expression>](#Prereq-Rules) The prerequisite logical expression.
      * `k8sPermissions`: Kubernetes RBAC permissions required to perform this action as the current user on the target cluster (optional).
        * `rules`: An array of conditional Kubernetes RBAC Rules
          * `ifExpression`:  A logical expression of [CASE Prereq Resolver](120-prereqs.md) JSON Pointers that must evaluate to `true` to consider the permission (optional)
          * `rule`: A  Kubernetes RBAC rule. See the [Kubernetes SelfSubjectAccessReviewSpec API for details](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.15/#resourceattributes-v1-authorization-k8s-io)
            * `group`: The API Group of the Resource. "*" means all. (required)
            * `name`: The name of the resource being requested for a "get" or deleted for a "delete". "" (empty) means all. (optional)
            * `namespace`: The namespace of the action being requested. (Optional, default=all)
            * `resource`: One of the existing resource types. "*" means all. (required)
            * `subresource`: One of the existing resource types. "" means none. (optional)
            * `verbs`: A list of kubernetes resource API verbs, for example: get, list, watch, create, update, delete, proxy. "*" means all. (required)
            * `version`: The API Version of the Resource. Absence or "*" means all. (optional)

## Prereq Rules
Prerequisite resolvers can be referenced as logical expressions using a subset of the [JSONLogic specification](http://jsonlogic.com/) and [JSON Pointers](https://tools.ietf.org/html/rfc6901).  Only logical expressions are supported.

Example:
```
actions:
  install:
    ...
    requires:
      and: 
        - or:
          - "/case/prereqs/k8sDistros/ibmCloud"
          - "/case/prereqs/k8sDistros/ibmCloudPrivate"
          - "/case/prereqs/k8sDistros/openshift"
        - or:
          - and: 
            - "!":
              - "/case/prereqs/k8sDistros/openshift"
            - or: 
              - "/case/prereqs/k8sResources/ibmRestrictedPSP"
              - "/case/prereqs/k8sResources/etcdControllerPSP"
          - and: 
            - "/case/prereqs/k8sDistros/openshift"
            - or:
              - "/case/prereqs/k8sResources/ibmRestrictedSCC"
              - "/case/prereqs/k8sResources/etcdControllerSCC"
```

This translates to:

* Install if:
  * Either the Kubernetes distribution is ibmCloud, ibmCloudPrivate or openshift
  * AND 
    * if openshift, then either the ibmRestrictedSCC or etcdControllerSCC resources must be installed.
    * if not openshift, then either the ibmRestrictedPSP or etcdControllerPSP resources must be installed. 

## Kubernetes Permission Rule Example

Example Rule:
```
actions:
  install:
    ...
    k8sPermissions:
      rules:
      - ifExpression
        - "!": 
          - "/case/prereqs/k8sDistros/openshift"
        apiGroups:
        - extensions
        resources:
        - podsecuritypolicies
        verbs:
        - get
        - list
        - watch
        - create
        - patch
        - update
        version: '*'

      - ifExpression:
          "/case/prereqs/k8sDistros/openshift"
        apiGroups: 
        - security.openshift.io
        resources:
        - securitycontextconstraints
        verbs:
        - get
        - list
        - watch
        - create
        - patch
        - update
```

This translates to:

* Check Permissions:
  * The Kubernetes distribution is NOT openshift:
    * Check permissions for the specified verbs for the podsecuritypolicies resource in the extensions API Group.
      * `kubectl auth can-i get podsecuritypolicies.extensions` 
      * `kubectl auth can-i list podsecuritypolicies.extensions` 
      * `kubectl auth can-i watch podsecuritypolicies.extensions` 
      * `kubectl auth can-i create podsecuritypolicies.extensions` 
      * `kubectl auth can-i patch podsecuritypolicies.extensions` 
      * `kubectl auth can-i update podsecuritypolicies.extensions` 
  * The Kubernetes distribution IS openshift:
    * Check permissions for the specified verbs for the securitycontextconstraints resource in the security.openshift.io API Group.
      * `kubectl auth can-i get securitycontextconstraints.security.openshift.io` 
      * `kubectl auth can-i list securitycontextconstraints.security.openshift.io` 
      * `kubectl auth can-i watch securitycontextconstraints.security.openshift.io` 
      * `kubectl auth can-i create securitycontextconstraints.security.openshift.io` 
      * `kubectl auth can-i patch securitycontextconstraints.security.openshift.io` 
      * `kubectl auth can-i update securitycontextconstraints.security.openshift.io` 

