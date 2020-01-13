## Introduction

This CASE shows how the etcd-operator project could be converted to a CASE. Some pieces of this project are intentionally inefficient in an effort to show specific scenarios for a CASE.

## Prerequisites

- Kubernetes 1.11 or later
- Helm 2.13 or later

## Resources Required

- At least 1GB of persistent storage, minimum 150m CPU and 256MB memory available for resource requests.

## Installing the CASE

The CASE has the following inventory items:

- `clusterSetup`: Contains the cluster-level Kubernetes resources required to deploy the Operator
- `namespaceSetup`: Contains the namespace-level Kubernetes resources to prepare a namespace for the Operator's controller pods
- `etcdOperators`: The etcd-operator Helm chart
- `etcBackupExample`: A sample etcBackup custom resource
- `etcClusterExample`: A sample etcCluster custom resource
- `etcRestoreExample`: A sample etcRestore custom resource

## Configuration

See each inventory item for specific configuration information.

## Limitations

- This product is limited to install on amd64 

## PodSecurityPolicy Requirements

The predefined PodSecurityPolicy name [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. If your target namespace is bound to this PodSecurityPolicy, you can proceed to install the chart.

Custom PodSecurityPolicy definition:
```

apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive,
      requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    #apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
    #apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
  name: ibm-restricted-psp-etcd
spec:
  allowPrivilegeEscalation: false
  forbiddenSysctls:
  - '*'
  fsGroup:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  requiredDropCapabilities:
  - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
```

## Red Hat OpenShift SecurityContextConstraints Requirements

This chart is supported on Red Hat OpenShift. The predefined SecurityContextConstraint name [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart.

Custom SecurityContextConstraints definition:
```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive,
      requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    cloudpak.ibm.com/version: "1.0.0"
  name: ibm-restricted-scc-etcd
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: false
allowedCapabilities: []
allowedFlexVolumes: []
allowedUnsafeSysctls: []
defaultAddCapabilities: []
defaultPrivilegeEscalation: false
forbiddenSysctls:
  - "*"
fsGroup:
  type: MustRunAs
  ranges:
  - max: 65535
    min: 1
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsNonRoot
seccompProfiles:
- docker/default
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: MustRunAs
  ranges:
  - max: 65535
    min: 1
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
priority: 0
```