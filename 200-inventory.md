# CASE inventory Specification
- [CASE inventory Specification](#case-inventory-specification)
  - [Status: Beta](#status-beta)
  - [Overview](#overview)
  - [`inventory` directory specification.](#inventory-directory-specification)
  - [Inventory item directory specification](#inventory-item-directory-specification)
  - [`inventory.yaml` Specification](#inventoryyaml-specification)

## Status:  Beta

## Overview
The inventory directory is a collection of inventory items.  Each of the inventory items are included as required or optional entities of the CASE.

## `inventory` directory specification.
The inventory directory contains sub-directories that represent Inventory Items.  Each inventory item directory is a path navigable name of the inventory item within the CASE specification.
* The `inventory` directory includes NO FILES.  It ONLY includes sub-directories that contain metadata about inventory items.
* The inventory item sub-directory name MUST follow the property name conventions defined in the [CASE YAML Specification](010-case-structure.md#YAML-File-Format)

Example file structure:
```
my-case/
  ...
  inventory/
    clusterSetup/             # Inventory Item 
      actions.yaml
      inventory.yaml
      README.md
      resources.yaml
      files/                  # Optional resources
    myApplication/            # Inventory Item
      actions.yaml
      inventory.yaml
      README.md
      resources.yaml
      files/                  # Optional resources
```

## Inventory item directory specification
Each inventory item directory MUST include the following files:
- [inventory.yaml](#inventoryyaml-Specification)
- README.md

Each inventory item directory MAY include the following files:
- [actions.yaml](220-actions.md) 
- [resources.yaml](210-resources.md)  

Each inventory item MAY include an optional `files` folder which includes any embedded resources that should be included the case.  See [resources.yaml](210-resources.md) for details.

## `inventory.yaml` Specification
The inventory item name MUST follow the [CASE property specification](010-case-structure.md#yaml-file-format).

The `inventory.yaml` has the following attributes:
* `inventory`: The resources object. (required)
  * `metadata`:  Information about the resources.
  * `k8sScope`: The Kubernetes scope this inventory item applies to.  For example: `cluster` or `namespace`
  
