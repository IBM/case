# Install etcd-operator

This inventory item contains the installer for the CASE.  The installer can be ran using the `cloudctl case launch` command.  The launch install script takes the following parameters that must be passed in via the `--args` flag in the `cloudctl case launch` command (note the args are a comma separated value list of arg=value format):

| arg name | type | description | required |
|----------|------|-------------|----------|
| imagePullSecret | string | name of the pull secret used to acces the image registry | yes |
| chartsFile | string | file path to the downloaded CASE archive charts csv file | yes |
| imageRegistry | string | image registry location the images are hosted in | yes |

This is the last step in the installation process, and should be ran after `loadAirgapResources` and `clusterSetup` launcher actions have been executed.

## Sample Command

```raw
$ cloudctl case launch -c <path_to_case> \
                       --namespace install-namespace \
                       --instance demo \
                       --inventory productInstall \
                       --action install \
                       --args "imagePullSecret=demo-pull-secret,chartsFile='case-archive-dir/case-charts.csv',imageRegisry=quay.io"
```