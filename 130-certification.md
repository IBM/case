# CASE certification.yaml Specification
- [CASE certification.yaml Specification](#case-certificationyaml-specification)
  - [Status: Beta](#status-beta)
  - [Overview](#overview)
  - [Specification](#specification)
- [Examples](#examples)
  - [IBM certified container Example](#ibm-certified-container-example)
  - [IBM certified Cloud Pak Example w/ Exception](#ibm-certified-cloud-pak-example-w-exception)
  - [IBM certified Minimum Catalog Example](#ibm-certified-minimum-catalog-example)


## Status:  Beta

## Overview
This specification supports multiple certifications.  Certifications are stored in the `certifications` directory in the CASE.  Certifications are added to the case when a certification is completed.

## Specification
Each certification file must be named as follows:  `<provider><type>.yaml`

Where the `provider` is the provider of the certification and the `type` is some value that describes the certification.  

The certification name must a total of 50 characters or less.
The `provider` MUST:
  * begin with a lower case character
  * contain alpha-numeric characters or the following special characters: `_`

The `type` MUST:
  * begin with a lower case character
  * contain alpha-numeric characters or the following special characters: `_-`


* `certification`: The certification object (required)
  * `metadata`:  Describes the certification.  See [CASE Metadata](010-case-structure.md#Specification-metadata-and-versioning) for details.
  * `id`: Unique string identifier assigned during certification (required)
  * `provider`: The certification provider identifier.  A provider must be unique by vendor or certification authority.  For example: `ibm`. See above for naming requirements.  (required)
  * `type`: The certification type unique to the certification provider. See above for naming requirements.  (required)
  * `issueDate`: The date in the format MM/DD/YYYY which the certification was issued (required)
  * `expirationDate`: The date in the format MM/DD/YYYY which the certification expires (required)
  * `terms` : The terms description (required)
  * `exceptions` : An array of exception(s) granted during certification (optional)
    * `id`: Unique string identifier for exception assigned during certification (required)
    * `description`: The description of the exception for documentation (required)
    * `remediation`:  Planned remediation of the exception for documentation (required)

__Defaults__ : 
- terms : "Valid from date of issue. Security vulnerability management and enhancements are delivered on the latest version of the chart and images", but may be overriden at certification if alternate terms approved.


# Examples 

## IBM certified container Example
```yaml
certification:
  metadata: 
    name: "ibmccs"
    displayName: "IBM certified container software"
  id: "75b05dfb-8988-4caa-8a6c-36f8ae5fe211"
  issueDate: "08/01/2019"
  expirationDate: "07/30/2020"
  terms: "Valid from date of issue. Security vulnerability management and enhancements are delivered on the latest version of the chart and images"
```

## IBM certified Cloud Pak Example w/ Exception
```yaml
certification:
  metadata: 
    name: "ibmccp"
    displayName: "IBM Certified Cloud Pak"
  id: "85b05dfb-8988-5caa-9a6c-36f8ae5fe212"
  issueDate: "10/01/2019"
  expirationDate: "03/31/2020"
  terms: "Valid from date of issue. Security vulnerability management and enhancements are delivered on the latest version of the chart and images"
  exceptions: 
    - id: "12345"
      description: "Non RedHat certificated operator <operatorname> : UBI image unavailable for community operator, verified manual per standards and supported by IBM"
      remediation: "Contribute UBI based image to community operator and RedHat Certify with next release"
  ```
  
  ## IBM certified Minimum Catalog Example
```yaml
certification:
  metadata: 
    name: "ibmmc"
    displayName: "IBM minimum catalog"
  id: "99b05dfb-8900-4caa-8a8c-36f8ae5fe333"
  issueDate: "01/01/2019"
  expirationDate: "12/31/2019",
  terms: "Valid from date of issue. Security vulnerability management and enhancements are delivered on the latest version of the chart and images"
```
