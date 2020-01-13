# etcd Namespace Setup
This readme provides instructions on how to manually install and configure the Kubernetes cluster to run the etcd Operator.

## Prerequisites

## Configuration
The following items need to be performed manually:
1.  Create a namespace.
2.  (Optional) Create or choose a Kubernetes user or group to administer the etcd cluster (the etcdAdministrator role)
3.  (Optional) Create a RoleBinding to bind the etcd user to the the `etcd-operator` ClusterRole
4.  (Optional) Create a NetworkPolicy
5.  (Optional) Create a ServiceAccount
6.  (Optional) Bind the ServiceAccount to the `ibm-restricted-psp` PodSecurityPolicy or `restricted` SecurityContextConstraint (OpenShift) 

## Removal
To remove this configuration
1.  `kubectl delete ns <namespace>`
