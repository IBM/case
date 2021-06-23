# CASE certification.yaml Specification
- [CASE certification.yaml Specification](#case-certificationyaml-specification)
  - [Status: Stable](#status-stable)
  - [Overview](#overview)
  - [Specification](#specification)
  - [Specifying certification type in case.yaml](#specifying-certification-type-in-caseyaml)
- [Examples](#examples)
  - [IBM certified container example](#ibm-certified-container-example)
  - [IBM certified Cloud Pak example w/ exception](#ibm-certified-cloud-pak-example-w-exception)
  - [IBM certified minimum catalog example](#ibm-certified-minimum-catalog-example)
  - [IBM certified container with security report example](#ibm-certified-container-with-security-report-example)
  - [Example case.yaml certifications section for an ibmccp license](#example-caseyaml-certifications-section-for-an-ibmccp-license)


## Status: Stable

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
* `resources`: The resources object for any additional certification-related files.
  * `metadata`:  Information about the resources.
  * `resourceDefs`: The resource resolvers.
    * `files`:  Array of file object references that are embedded in this CASE inventory item.
      * `metadata`:  Metadata about the file reference.
      * `ref`:  The relative path to the `files` directory.
      * `mediaType`:  The media type of the file as supported by this spec.  See [Media Types](#Media-Types).

__Defaults__ : 
- terms : "Valid from date of issue. Security vulnerability management and enhancements are delivered on the latest version of the chart and images", but may be overriden at certification if alternate terms approved.

## Specifying certification type in case.yaml

`case.yaml` contains a `certifications` object which should contain a list of certifications for the CASE. The values in this section should match the certification file names in your `certifications/` directory.

# Examples 

## IBM certified container example
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

## IBM certified Cloud Pak example w/ exception
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
  
## IBM certified minimum catalog example
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

## IBM certified container with security report example
```yaml
certification:
  metadata: 
    name: "ibmccs"
    displayName: "IBM certified container software"
  id: "75b05dfb-8988-4caa-8a6c-36f8ae5fe211"
  issueDate: "08/01/2019"
  expirationDate: "07/30/2020"
  terms: "Valid from date of issue. Security vulnerability management and enhancements are delivered on the latest version of the chart and images"
resources:
  metadata:
    name: certReport
    displayName: certReport
    displayDescription: certification security report
  resourceDefs:  
    files:
    - ref: ExternalSecurity.pdf
      mediaType: application/pdf
```

  ## Example case.yaml certifications section for an ibmccp license
```yaml
  certifications:
    ibmccp: {}
```
