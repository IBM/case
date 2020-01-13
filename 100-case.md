# CASE case.yaml Specification
- [CASE case.yaml Specification](#case-caseyaml-specification)
  - [Status: Beta](#status-beta)
  - [Overview](#overview)
  - [Specification](#specification)
    - [version](#version)
      - [version examples](#version-examples)
    - [supports](#supports)
      - [architectures](#architectures)
      - [k8sDistros](#k8sdistros)
      - [managedPlatforms](#managedplatforms)

## Status:  Beta

## Overview
The `case.yaml` file is a YAML document that follows the [CASE YAML rules](010-case-structure.md).  The `case.yaml` is a base object that includes information about the CASE.

## Specification
The `case.yaml` has the following attributes:
* `specVersion`:  The CASE specification version that this CASE instance implements (required String).  For example: `1.0.0`.
* `name`: The globally unique name of the CASE (required String) with the following limitations:
  * must be 50 characters or less
  * begin with a lower case character
  * contain alpha-numeric characters or the following special characters: `-_`
* `displayName`: The human readable name of the CASE (optional String).
* `version`: The Semver 2 version of the CASE (required String).  This version must be updated each time a CASE is updated.  See the [version documentation.](#version)
* `appVersion`: The version of the application or product that this CASE represents.  This value can be any string that matches the organization versioning standards.
* `description`:  The description of the CASE (required String).
* `displayDescription`:  The displayable description of the CASE (optional String).
* `icons`:  An array of encoded icon definitions for the project (optional)
  * `base64`: The base64 encoded binary representation of the image (PNG or SVG) (optional if url is specified)
  * `mediaType`: The media-type of the image.  One of: `image/png` or `image/svg+xml` (required)
  * `url`:  The URL of the image if not embedded. (optional if base64 is specified)
* `organization`: The name of the organization/distributor of the CASE (String).
* `certifications`: Summary of the certifications this CASE provides.  Details are provided in the [certification.yaml](130-certification.md) file.
* `supports`: Describes various levels of support for this CASE. (CASE Objects) See the [supports](#supports) section for details.
  * `architectures`: Compute [architectures](#architectures). (CASE Object) 
  * `k8sDistros`: [Kubernetes distributions](#k8sdistros). (CASE Object)
  * `managedPlatforms`: [Managed platforms](#managedplatforms). (CASE Object)
* `classifications`: The type of license or usage classifiers for this CASE. (CASE Objects) 
* `catalogs`: Catalog categories which this software applies to in a catalog. (CASE Objects) 
* `webPage`: The URL of the page that consumers can reference for additional information about this CASE. (String)
* `licenses`: All of the licenses that pertain to the software in this CASE.
  * `<license-key>` A license name e.g. apache2 (CASE Object)
    * `metadata`: Metadata about the licence.  The `name` must match the license-key if provided.
    * `ref`:  The relative path to the license in the `licenses` directory (Required)
    * `url`:  A URL to the license.  This must reference the same license as the `ref`.  This may be used to link to translated licenses (Optional)
    * `mediaType`:  The (MIME) media type of the license file.

### `version`
A CASE typically represents a single product, but can be composed of many embedded components and products that collectively provide a version.  CASE `version` extends semantic versioning in such a way that allows the CASE producer and consumer to quickly identify the scope of a functional or non-functional change.

The format of the version in Backus-Naur Form, where several tokens are defined in [semver.org](https://semver.org/#backusnaur-form-grammar-for-valid-semver-versions)
```
<valid semver>            ::= <version core>
                            | <version core> "-" <pre-release>
                            | <version core> "+" <version non-functional>
                            | <version core> "-" <pre-release> "+" <non-functional-version>
<version core>            ::= <major> "." <minor> "." <patch>
<version non-functional>  ::= <datetime> |
                              <datetime> "." <build>
<datetime>                ::= <YYYYMMDD> "." <HHmmSS>
```

The `version core` portion of the version is the typical semver `major.minor.patch` version semantic that descrbes the functional changes that the CASE product has implemented between this version an the previous version.  The `version core` represents the ENTIRE CASE and all components and products within it.

The `version non-functional` portion of the version is located in the first two tokens of the semver build section and is represented by a date/time in the gregorian calendar format: `YYYYMMDD-HHmmSS`, where:
- `YYYY` is the year, 
- `MM` the month (including leading zero), 
- `DD` the day of the month (including leading zero),
- `HH` the hour of the day (including leading zero),
- `mm` the minute of the hour (including leading zero)
- `ss` the second of the minute (including leading zero)

Unlike semver, this specification applies precedence to the `version non-functional` portion of the build to allow sorting and retrieving the latest non-functional version within a given functional version.  If the `version non-functional` value is not supplied, it is assumed to be equivalent to `000000.000000`.

#### version examples
- Initial version without a build.
  
  `1.0.0`
- Update the `README.md`.  The two versions are functionally equivalent, but the latest version is:

  `1.0.0+20191008.070012`

- Update the `prereqs.yaml` to add an additional Kubernetes distribution.  There are now 3 functionally equivalent versions, but the latest version is:

  `1.0.0+20191008.162055`

- Create a patch with a security fix with a custom build notation.  The latest functional version is now:

  `1.0.1+20191009.070000.cve2019-1234`

- Add a new feature.
  
  `1.1.0+20191115.070522`

- Create a new version with API incompatibilities

  `2.0.0`

- Bug fix/patch for the 1.1 stream

  `1.1.1+20200117.080221`



### `supports`
The supports CASE object defines various features that are supported by the CASE and product defined in the case.  Specific details are described in the inventory items.

The following support objects are available:

#### `architectures`
This describes the compute architectures supported by the CASE.  Some specific values include:
* `amd64`:  64-bit Intel/AMD x86
* `ppc64le`: 64-bit little-endian PowerPC
* `s390x`: Linux on IBM Z

Example supporting all three architectures:
```yaml
supports:
  architecture: 
    amd64: {}
    ppc64le: {}
    s390x: {}
```

#### `k8sDistros`
This describes the Kubernetes distributions that are supported by the CASE and product defined in the case.  Some specific values include:

* `icp`: IBM Cloud Private
* `iks`: IBM Kubernetes Service
* `rhocp3`: RedHat OpenShift Container Platform 3
* `rhocp4`: RedHat OpenShift Container Platform 4 (required)
* `aks`: Microsoft Azure
* `gce`: Google Compute Engine
* `eks`: Amazon Enterprise Kubernetes Service

Example supporting several Kubernetes distributions:
```yaml
supports:
  k8sDistros: 
    icp: {}
    iks: {}
    rhocp3: {}
    rhocp4: {}
```


#### `managedPlatforms`
This describes the managed platforms supported by the CASE and product defined in the case.  Managed platforms generally describe a vendor cloud and the supporting frameworks.  Some specific values include:

* `ibm`:  The IBM Cloud
* `amazon`: The Amazon cloud
* `redhat`: The RedHat cloud
* `google`: The Google cloud
* `microsoft`: The Microsoft cloud

Example supporting a few managed platforms:
```yaml
supports:
  managedPlatforms: 
    ibm: {}
    amazon: {}
```
