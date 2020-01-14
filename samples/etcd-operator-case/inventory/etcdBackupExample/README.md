# etcd Backup Exaample
This readme provides instructions on installing the etcdBackup custom resource

## Prerequisites
A Kubernetes cluster with the etcd Operator installed, an etcd cluster created, and the etcdBackup Custom Resource Definition created.

## Installation
### Roles required
- Etcd Administrator

### Steps
1. Complete the parameters in `files/etcdBackupExample.yaml`
1. Login to kubectl as an etcd administrator.
1. `kubectl apply -f files/etcdBackupExample.yaml`
