# CASE Repository Specification

- [CASE Repository Specification](#case-repository-specification)
  - [Status:  Beta](#status-beta)
  - [Overview](#overview)
  - [Specification](#specification)
  - [Files and Folders](#files-and-folders)
    - [Descriptors](#descriptors)
      - [Repository base index descriptor](#repository-base-index-descriptor)
      - [CASE product index descriptor](#case-product-index-descriptor)
      - [CASE product version descriptor](#case-product-version-descriptor)
    - [Semver and Semver Comparison Formats](#semver-and-semver-comparison-formats)

## Status:  Beta

## Overview
The CASE repository is a location where CASE packages can be stored and shared. The folder and file names are well-defined such that traversing through the repository can be done without querying the contents of a directory.

## Specification
A CASE repository is made up of three levels of directories, each containing a descriptor file for that level.

## Files and Folders

The files described here are well named unless included in `<brackets>`, in which a name is based on the CASE name or version.

```
index.yaml                              # A file containing a list of all CASEs in this repository
<case-name>/                            # A folder containing one or more versions of a CASE
  index.yaml                            # A file containing information about the CASE and a list of the versions available in the repository
  <case-version>/                       # A folder containing a specific version of a CASE
    version.yaml                        # A file describing the version of the CASE in this directory
    <case-name>-<case-version>.tgz      # The CASE tgz file
```

### Descriptors

Each directory in the CASE repository contains a descriptor file with information about the contents of the directory. The descriptor at the repository base directory and at the CASE directory is named `index.yaml` while the descriptor for a specific version of a CASE is named `version.yaml`.

#### Repository base index descriptor

The repository base index provides a list of all of the CASEs hosted in the repository and includes the latest version and associated application version.

* `apiVersion`: The CASE repository index API version. (Required)
* `entries`: A list of CASEs that are in this CASE repository. (Required)
  * `<CASE>`: The name of the CASE
    * `latestVersion`: The latest version of the CASE in the repository (Required)
    * `latestAppVersion`: The latest application version of this CASE in the repository (Required)

Example:

```
apiVersion: v1
entries:
  etcd-operator-case:
    latestVersion: 1.0.0
    latestAppVersion: 3.0.0
  redis-case:
    latestVersion: 1.2.1
    latestAppVersion: 5.0.0
```

#### CASE product index descriptor

The CASE product index provides additional information about the product including a list of versions and associated app versions available in the CASE repository.

* `apiVersion`: The CASE repository index API version. (Required)
* `latestVersion`: The latest version of the CASE in the repository (Required)
* `latestAppVersion`: The latest application version of this CASE in the repository (Required)
* `versions`: A list of versions of the CASE available in the repository (Required)
  * `<Version>`: The CASE version
    * `appVersion`: The application version associated with this version of the CASE (Required)

Example:

```
apiVersion: v1
latestVersion: "1.0.0"
latestAppVersion: "3.0.0"
versions:
  1.0.0:
    appVersion: "3.0.0"
```

#### CASE product version descriptor

The CASE version descriptor provides information about the specified version of the product.

* `specVersion`: The CASE spec version this CASE is written against. (Required)
* `created`: The date this CASE was created. (Required)
* `digest`: The cryptographic hash of this CASE. (Required)
* `case` : The CASE object from the case.yaml (Required).  See [case.yaml](100-case.md).

Example:

```
specVersion: 1.0.0
created: 2019-09-30T16:00:00.45234224-06:00
digest: "sha256:4684ee693b6c5caf9d717cbaa06338d8e19841c39091c90295deb76d567810ec"
case:
  apiVersion: v1
  version: 1.0.0
  appVersion: 1.0.0
  name: etcd-operator-case
  displayName: "Sample IBM certified container CASE"
  description: "Sample IBM certified container CASE"
  webPage: https://github.com/coreos/etcd-operator
  organization: "coreos"
  catalogs:
    database: {}
  certifications:
    container: {}
  classifications:
    opensource: {}
    experimental: {}
    sample: {}
  supports:
    architectures:
      amd64: {}
      ppc64le: {}
      s390x: {}
    k8sDistros:
      rhocp3: {}
    managedPlatforms:
      ibm: {}
  icons:
    - url: https://raw.githubusercontent.com/CloudCoreo/etcd-cluster/master/images/icon.png
      mediaType: image/png
```

### Semver and Semver Comparison Formats
This specification uses the [Semantic Version 2.0.0 specification](https://semver.org/) (semver) for describing versions of entities.