# etcd Cluster Exaample
This readme provides instructions on installing the etcdCluster custom resource

## Prerequisites
A Kubernetes cluster with the the etcd Operator installed, including the etcdCluster Custom Resource Definition.

## Installation
### Roles required
- Etcd Administrator

### Steps
1. Complete the parameters in `files/etcdClusterExample.yaml`
1. Login to kubectl as an etcd administrator.
1. `kubectl apply -f files/etcdClusterExample.yaml`
