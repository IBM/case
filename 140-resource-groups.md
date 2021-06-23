# CASE case.yaml Specification
- [CASE case.yaml Specification](#case-caseyaml-specification)
  - [Status: Stable](#status-stable)
  - [Overview](#overview)
  - [Specification](#specification)
    - [Description](#description)
    - [Example](#example)

## Status: Stable

## Overview
The `resourceGroups.yaml` file contains a collection of groups defined elsewhere in the CASE and is provided for the simplification of handling these groups. Currently, only image groups exist in the CASE specification and are defined in the [CASE resources.yaml specification](210-resources.md). `resourceGroups.yaml` defines a collection of groups and provides the ability to define product components and configurations.

## Specification
* `resourceGroups`: The resourceGroups object (required)
  * `resourceGroupsDefs`: The resource group
    * `<resource_group_name>`: A [CASE Property](100-case.md##YAML-File-Format) defining the resource group.  For example: `trial` (required)
      * `metadata`: Describes the resource group.  See [CASE Metadata](010-case-structure.md#Specification-metadata-and-versioning) for details on metadata
        * `default`: A boolean metadata parameter. If set to true, designates that this is the default image group for the CASE. Only one resource group may be designated as the default for a CASE.
      * `groups`: A list of groups that make up this resource group (required)
        * `name`: The group name (required)

### Description

A CASE can define one or more groups within the `resources.yaml` files in each of the CASE's inventory items (see [Container Image Groups](210-resources.md#container-image-groups)). These groups provide a granular way to create components or configurations within a CASE without needing to create separate CASEs for each component or configuration. `resourceGroups.yaml` provides an additional layer to allow for combining multiple groups into a single definition for easier consumption.

### Example

The following example shows a `resourceGroups.yaml` defining two groups, `demo` and `prod`, and sets the demo group to be the default group for the CASE:

```
resourceGroups:
  resourceGroupsDefs:
    demo:
      metadata:
        default: true
      groups:
      - name: "demoImages"
      - name: "coreComponents"
    prod:
      groups:
      - name: "prodImages"
      - name: "coreComponents"
      - name: "prodDatabase"
```