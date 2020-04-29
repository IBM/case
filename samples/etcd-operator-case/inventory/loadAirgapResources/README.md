# Load the Airgap Archive

This inventory item provides example scripting and case launch actions to load the images from the airgap archive to a bastion server (or boot stick).  This data can then be transfered to within the network, and the install action can be launched to deploy the product.  The installer can be ran using the `cloudctl case launch` command.  The launch install script takes the following parameters that must be passed in via the `--args` flag in the `cloudctl case launch` command (note the args are a comma separated value list of arg=value format):

| arg name | type | description | required |
|----------|------|-------------|----------|
| imagesFile | string | file path to the downloaded CASE archive images csv file  | yes (if caseArchiveDir is not specified) |
| toRegistry | string | name of the registry the images are to be saved to | yes |
| caseArchiveDir | string | file path to the downloaded CASE archive directory | yes |

This is the first step in the installation process, and should be ran before `clusterSetup` and `productInstall` launcher actions are executed.

## Prereqs

1. Docker must be configured to use the default credentials store (docker configuration json)
1. `docker login` must be performed in order to properly transfer images from registries

## Sample Command

```raw
$ cloudctl case launch -c <path_to_case> \
                       --namespace install-namespace \
                       --instance demo \
                       --inventory loadAirgapResources \
                       --action ocMirror \
                       --args "imagesFile='case-archive-dir/case-images.csv',imageRegisry=quay.io"
```

```raw
$ cloudctl case launch -c <path_to_case> \
                       --namespace install-namespace \
                       --instance demo \
                       --inventory loadAirgapResources \
                       --action ocMirror \
                       --args "toRegistry='case-archive-dir',imageRegisry=quay.io"
```