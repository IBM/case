# CASE digests.yaml Specification
- [CASE digests.yaml Specification](#case-digestsyaml-specification)
  - [Status: Beta](#status-beta)
  - [Overview](#overview)
  - [Specification](#specification)
    - [Resource Digests](#resource-digests)

## Status:  Beta

## Overview
The `digests.yaml` includes digests (cryptographic hashes) of select artifacts within the CASE specification.  Specifically, the artifacts that are not part of the canonical JSON representation of the CASE.  This includes:
1.  License files
2.  Inventory Resource Files
3.  Inventory Resource References

## Specification
The `digests.yaml` has the following attributes:
* `digests`: The digests available to the CASE inventory item actions.
  * `metadata`:  Describes the digests.  See [CASE Metadata](010-case-structure.md#Specification-metadata-and-versioning) for details.
  * `digestDefs`:  The role definition objects.
    * `readme`:  The digest of the CASE `README.md` file.
      * `digest`: The digest for the README.
      * `size`: The README size.
      * `skip`: If true, skip this entry when evaluating the digest.
    * `inventory`: The inventory items.
      * `<Inventory Item>`:  The name of the inventory item.
        * `readme`:  The readme.md file.
          * `digest`: The digest for the README.
          * `size`: The README size.
          * `skip`: If true, skip this entry when evaluating the digest.
        * `resources`: A list of resources
          * `resourceDefs`: The resource resolvers.
            * `cases`: Array of digest objects for referenced cases
              * `digest`: A CASE archive digest.
              * `size`: The CASE archive size.
              * `skip`: If true, skip this entry when evaluating the digest.
            * `files`: Array of digest objects for referenced files.
              * `digest`: Array of digest strings.
              * `size`: The file size.
              * `skip`: If true, skip this entry when evaluating the digest.
            * `helmCharts`: Array of digest objects for referenced Helm charts
              * `digest`: Array of digest strings.
              * `size`: The Helm Archive size. 
              * `skip`: If true, skip this entry when evaluating the digest.
        * `imageManifest`: Image digests by image repository as defined in the [IBM Cloud offline package manifest.yaml](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.0/app_center/add_package_offline.html)
          * `images`: Array of images
              * `references`: Array of image repositories.
                * `digest`: The digest of the image.  This is the Docker V2 Repository full length Image ID. See the [docker commandline reference](https://docs.docker.com/engine/reference/commandline/images/#list-the-full-length-image-ids).
                * `size`: The container image size. 
                * `skip`: If true, skip this entry when evaluating the digest.
    * `licenses`: The main license.
      * `digest`: The digest of the license file.
      * `size`:  The file size.
      * `skip`: If true, skip this entry when evaluating the digest.
    * `case`: The non-file elements of the CASE.
      * `digest`: The digest of the canonical representation of the case.
      * `size`: The size of the canonical representation of the case.
      * `skip`: If true, skip this entry when evaluating the digest.
    * `licenses`: The licenses.
      * `<License Item>`:  The key of the license item.
        * `digest`: The digest of the license file.
        * `size`:  The file size.
        * `skip`: If true, skip this entry when evaluating the digest.
    

### Resource Digests
Each resource digest is in the following format described in the 
[OCI Digest](https://github.com/opencontainers/image-spec/blob/master/descriptor.md#digests) specification:

```
digest                ::= algorithm ":" encoded
algorithm             ::= algorithm-component (algorithm-separator algorithm-component)*
algorithm-component   ::= [a-z0-9]+
algorithm-separator   ::= [+._-]
encoded               ::= [a-zA-Z0-9=_-]+
```

Supported algorithms include:
* `sha256`:  a collision-resistant hash function, chosen for ubiquity, reasonable size and secure characteristics. Implementations MUST implement SHA-256 digest verification for use in descriptors.  The encoded portion MUST match /[a-f0-9]{64}/. Note that [A-F] MUST NOT be used here.
