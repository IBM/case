# etcd Cluster Setup

This readme provides instructions on how to install and configure the Kubernetes cluster to run the etcd Operator using the `cloudctl case launch` framework.  The installer can be ran using the `cloudctl case launch` command.  The launch install script takes the following parameters that must be passed in via the `--args` flag in the `cloudctl case launch` command (note the args are a comma separated value list of arg=value format):

| arg name | type | description | required |
|----------|------|-------------|----------|
| imageRegistryUser | string | image registry username to generate the pull secret from | yes (if images in a password protected registry) |
| imageRegistryPass | string | image registry password to generate the pull secret from | yes (if images in a password protected registry) |
| createNamespace | bit | if 1, will create the namespace passed in through the `--namespace` flag to `cloudctl`, if 0 will assume the namespace has been precreated | no |
| imageRegistry | string | registry name where the images are to be pulled from (ex quay.io) | yes |
| pullSecretName | string | name of the pull secret to be created (used later in the productInstall step) | yes | 

This is the second step in the installation process, and should be ran before `productInstall` and after `loadAirgapResources` launcher actions are executed.

## Prerequisites

This CASE is supported on IBM Kubernetes Service (IKS), IBM Cloud Private (ICP) or Red Hat Openshift Container Platform running Kubernetes 1.11.0 or later on amd64 Linux.

## Sample Command

```raw
$ cloudctl case launch -c <path_to_case> \
                       --namespace install-namespace \
                       --instance demo \
                       --inventory clusterSetup \
                       --action setup \
                       --args "imageRegistryUser='testuser@email.com',imageRegistryPass='P@ssw0rD',createNamespace=1,imageRegistry='quay.io',pullSecretName=my-pull-secret"
```


## Installation
The Cluster Setup includes the cluster-scoped Kubernetes resource required to install the etcd Operator.

### Roles required

- Cluster Administrator

### Steps (manual)
1.  Login to kubectl as a cluster administrator.
1.  `cd inventory/clusterSetup/files`
1.  `kubectl apply -f .`

A namespace administrator can now install the Helm chart in `inventory/ectdOperators` with the create custom resource definition parameters set to false.

### Steps (case launch)

1. Login to kubectl as a cluster administrator
1. `$ cloudctl case launch <arg_strings_here>`


