# etcd Cluster Setup
This readme provides instructions on how to manually install and configure the Kubernetes cluster to run the etcd Operator.

## Prerequisites

This CASE is supported on IBM Kubernetes Service (IKS), IBM Cloud Private (ICP) or Red Hat Openshift Container Platform running Kubernetes 1.11.0 or later on amd64 Linux.

## Installation
The Cluster Setup includes the cluster-scoped Kubernetes resource required to install the etcd Operator.

### Roles required

- Cluster Administrator

### Steps
1.  Login to kubectl as a cluster administrator.
1.  `cd inventory/clusterSetup/files`
1.  `kubectl apply -f .`

A namespace administrator can now install the Helm chart in `inventory/ectdOperators` with the create custom resource definition parameters set to false.