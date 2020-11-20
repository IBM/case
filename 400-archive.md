# CASE Archive Specification
- [CASE Archive Specification](#case-archive-specification)
  - [Status: Stable](#status-stable)
  - [Overview](#overview)
  - [Specification](#specification)
    - [Archive Name](#archive-name)
    - [Archive contents](#archive-contents)

## Status: Stable

## Overview
A CASE Archive is TGZ (GZipped Tarball) of the files in the CASE directory structure. 

## Specification

### Archive Name
The archive name must match the name of the case:
```
Archive Name = CASE Name "-" Version ".tgz"
Version      = The case.version
CASE Name    = The case.name / CASE directory name
```

### Archive contents
The root directory of the archive must be the CASE folder.  

Example, to create a CASE archive of the `mydatabase` CASE, version 1.0.0+20191113.1530.cve2019-1234 (with a consistent hash):
```
> cd /tmp/mycases
> ls -1
myapp
mydatabase
> tar -cf - mydatabase/ | gzip -nc > mydatabase-1.0.0+20191113.1530.cve2019-1234.tgz
> ls -1
myapp
mydatabase
mydatabase-1.0.0+20191113.1530cve2019-1234.tgz
```

See the [createArchive.sh](utilities/createArchive.sh) for an example on how a CASE archive can be built with the correct directory format and a consistent digest/hash.
