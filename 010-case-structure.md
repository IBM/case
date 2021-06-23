# CASE Directory and File Structure Specification

- [CASE Directory and File Structure Specification](#case-directory-and-file-structure-specification)
  - [Status: Stable](#status-stable)
  - [Overview](#overview)
  - [Specification](#specification)
    - [Files and Folders](#files-and-folders)
    - [YAML File Format](#yaml-file-format)
    - [Canonical Flat CASE Format](#canonical-flat-case-format)
    - [Specification metadata and versioning](#specification-metadata-and-versioning)
    - [Entity References](#entity-references)
    - [Logical Operations](#logical-operations)
    - [Semver and Semver Comparision Formats](#semver-and-semver-comparision-formats)


## Status: Stable

## Overview

## Specification
The CASE is a well defined file and directory structure.
* Each folder MUST NOT include any other folders or files unless otherwise noted.

### Files and Folders
The files described here are well named unless included in `<brackets>`, in which a name is user-defined.
```
<case-name>/                   # The name of the folder that encompasses the CASE. It must be named the same as the CASE. See the CASE name specification: 100-case.md for details. (Required)
  case.yaml                    # CASE descriptor YAML file. (Required)
  certifications/              # Certification information. (Optional)
    <certification>            # One or more certification files. See the certification specification: 130-certification.md for details. (Required if folder exists)
  inventory/                   # Directory of inventory items. One sub-directory per item. (Required)
    <item>/                    # Directory of a single inventory item. (Required)
                                  Must include at least 1-N directories.
      inventory.yaml           # The metadata that describes an inventory item. (Required)
      actions.yaml             # The actions that can be performed on this inventory item. (Optional)
      README.md                # Human readable documentation about the inventory item. (Required)
      resources.yaml           # The metadata about each resource referenced or embedded with this inventory item. (Optional)
      files/                   # Embedded files referenced in the resources.yaml. (Optional)
  README.md                    # Human readable documentation about the CASE. (Required)
  prereqs.yaml                 # Prerequisites and dependency references for the CASE inventory. (Required)
  roles.yaml                   # Roles required to apply actions on inventory items in the CASE. (Required)
  LICENSE                      # A text file with the contents of the Apache 2.0 license. (Required)
  licenses/                    # UTF-8 encoded text file licenses that apply to the inventory items in the CASE if different from the CASE license. (Optional)
  signature.yaml               # The digital signature that verifies the authenticity of the CASE. (Optional)
```

### YAML File Format
* All YAML files MUST follow the following rules:
  * YAML format must follow a subset of the [YAML v1.2 specification](https://yaml.org/spec/1.2/spec.html) as follows:
    * YAML must resolve to canonical JSON using the JSON Canonicalization Scheme (JCS) [draft-rundgren-json-canonicalization-scheme-00](https://github.com/cyberphone/json-canonicalization)
    * YAML must pass validation using the included JSONSchema file.
  * YAML file can include comments, but may be discarded by processing engines.
* Fields and elements included in the YAML that are not included in the JSONSchema associated with the specification version defined in the `case.yaml` ARE NOT SUPPORTED and may be discarded or ignored.
* Property names:
  * SHOULD be meaningful names with defined semantics.
  * MUST be camel-cased, ascii strings.
  * The first character MUST be a letter, an underscore (_) or a dollar sign ($).
  * Subsequent characters CAN be a letter, a digit, an underscore, or a dollar sign.
  * Reserved [JavaScript keywords](https://docs.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-2010/ttyab5c8(v=vs.100)) should be avoided.
  * Maximum length MUST be 50 characters or less.

### Canonical Flat CASE Format
Each YAML file includes a subset the of the CASE definition, which makes it easier to identify optional vs. required portions of the specification, and makes it easier for build processes and source control systems to organize the information.

The overall format of the flattened CASE document is:
```
case:
  case:
    <the case.yaml>
  roles:
    <roles object in role.yaml>
  prereqs:
    <prereqs object in prereqs.yaml>
  inventories:
    <inventory name>
      inventory:
        <inventory object in inventory.yaml>
        resources:
          <resources object in resources.yaml>
        actions:
          <actions object in actions.yaml>
  certifications:
    <certification name>
      <certification object>
```

See the included utility script [flattenCase.sh](utilities/flattenCase.sh) to produce a single YAML file.

### Specification metadata and versioning
Each CASE object (e.g. roles) except for the top level CASE object itself, includes an optional `metadata` object.  This object includes metadata about the object and what specification version it implements.

The metadata object includes the following properties:
  * `specVersion`:  The version of the specification that the enclosing object schema represents (optional).  This is used as an override and should not normally be used.
  * `name`:  The name of the object (optional). 
  * `displayName`:  The displayable name (optional).
  * `description`:  The description of the object (optional).
  * `displayDescription`:  The displayable description (optional).
  
Additional properties MAY be added.  To avoid collisions with future versions of the specification, use a unique prefix or the character prefix: `$` or `_`


Example:
```
metadata:
  specVersion: 0.1.
  name: myResource
  displayName: My Resource
  description: This is My Resource... Additional notes about it here....
  displayDescription:  My Resource and more about it.
  _myInformation:  
    buildVersion: 20191231
```

### Entity References
There are several YAML files that reference attributes from other entities in other YAML files.

To reference an attribute or object within the same document or across documents:
*  Use the JSON Pointer format [RFC6901](https://tools.ietf.org/html/rfc6901)
*  Use the canonicalized (flattened) format of hte specification to locate the path of target entities.

### Logical Operations
The logical operations will follow the [json-logic](http://jsonlogic.com/) model.  So a json logic compliant yaml file like the following: 
```yml
and: 
  - or:
    - "/prereqs/k8sDistros/ibmCloud"
    - "/prereqs/k8sDistros/ibmCloudPrivate"
    - "/prereqs/k8sDistros/openshift"
  - or:
    - and: 
      - "!":  # notice the quotes because ! represents a tag
        - "/prereqs/k8sDistros/openshift"
      - or: 
        - "/prereqs/k8sResources/ibmRestrictedPSP"
        - "/prereqs/k8sResources/etcdControllerPSP"
    - and: 
      - "/prereqs/k8sDistros/openshift"
      - or:
        - "/prereqs/k8sResources/ibmRestrictedSCC"
        - "/prereqs/k8sResources/etcdControllerSCC"
```
can be parsed into json.

The logical operators and, or, not operate on a set of resolvers.  So a boolean expression like `((A && B) || (!C  && (E || F)))` would translate to:

```yml
or:
  - and:
    - A
    - B
  - and:
    - not:
      - C
    - or:
      - E
      - F
```

### Semver and Semver Comparision Formats
This specification uses the [Semantic Version 2.0.0 specification](https://semver.org/) (semver) for describing versions of entities. 
