# CASE roles.yaml Specification
- [CASE roles.yaml Specification](#case-rolesyaml-specification)
  - [Status: Stable](#status-stable)
  - [Overview](#overview)
  - [Specification](#specification)

## Status: Stable

## Overview
The `roles.yaml` includes metadata about the role an actor can play when running an Action on an Inventory Item.  

## Specification
The `roles.yaml` has the following attributes:

* roles: The roles available to the CASE inventory item actions.
  * `metadata`:  Desribes the roles.  See [CASE Metadata](010-case-structure.md#Specification-metadata-and-versioning) for details.
  * `roleDefs`:  The role definition objects.
    * `<Role Name>`:  A [CASE Property](010-case-structure.md#yaml-file-format) describing the role.  (Required)
      * `metadata`:  Describes the role.  See [CASE Metadata](010-case-structure.md#Specification-metadata-and-versioning) for details.

