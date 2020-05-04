#!/bin/bash

#
# Installs the ectd-operator-case
# Usage: install.sh [-a args] [-j casejsonpath] [-o operation] [-i instancename] [-n namespace] -c casepath
# 
# The additional args parameters include: createNamespace, pullSecretName, chartsFile, imageRegistry
#

# default values
installType="all"
createNamespace=0
pullSecretName="default"
caseJsonFile=""
casePath=""
inventory=""
action=""
namespace=""
instance=""
args=""
chartsFile=""
imageReg=""


print_usage () {
  echo "usage: install.sh [--caseJsonFile casejsonpath --inventory inventoryItemOfLauncher --action launchAction] --args \"--createNamespace=true --imagePullSecret=pullSecretName --chartsFile chartsFilePath --imageRegistry internalImageRegistry\" --casePath casepath --instance instancename --namespace namespace"
  if [ -z $1 ]; then
    exit 1
  else
    exit $1
  fi
}

# Parses the args (--args) parameter if specified
parse_dynamic_args () {
  _IFS=$IFS
  IFS=" "
  read -ra arr <<< "${1}"
  IFS="$_IFS"
  arr+=("")
  idx=0
  v="${arr[${idx}]}"

  while [ "$v" != "" ]; do
    case $v in
      --createNamespace)
      idx=$(( idx + 1 ))
      v="${arr[${idx}]}"
      if [ "${v}" = "true" ] || [ "${v}" = "1" ]; then
        createNamespace=1
      fi
      ;;
      --chartsFile)
      idx=$(( idx + 1 ))
      v="${arr[${idx}]}"
      chartsFile="${v}"
      ;;
      --imageRegistry)
      idx=$(( idx + 1 ))
      v="${arr[${idx}]}"
      imageReg="${v}"
      ;;
      --pullSecretName)
      idx=$(( idx + 1 ))
      v="${arr[${idx}]}"
      pullSecretName="${v}"
      ;;
      --help)
      print_usage 0
      ;;
      *)
      echo "Invalid Option ${v}" >&2
      exit 1
      ;;
    esac
    idx=$(( idx + 1 ))
    v="${arr[${idx}]}"
  done
  foundError=0
  if [ -z $pullSecretName ]; then
    echo "Error: The pullSecretName parameter was not specified with the --args parameter."
    foundError=1
  fi
  if [ -z $chartsFile ]; then
    echo "Error: The chartsFile parameter was not specified with the --args parameter."
    foundError=1
  fi
  if [ -z $imageReg ]; then
    echo "Error: The imageRegistry parameter was not specified with the --args parameter."
    foundError=1
  fi
  if [ $foundError -eq 1 ]; then
    print_usage
  fi
}

# Validates that the required parameters were specified
check_cli_args () {
  foundError=0
  if [ -z $casePath ]; then
    echo "Error: The case path parameter was not specified."
    foundError=1
  else
    ls $casePath/case.yaml > /dev/null
    if [ $? != 0 ]; then
      echo "Error: No case.yaml in the root of the specified case path parameter."
      foundError=1
    fi
  fi

  parse_dynamic_args

  if [ $foundError -eq 1 ]; then
    print_usage
  fi
}

# Verifies that we have a connection to the Kubernetes cluster
check_kube_connection () {
  kubectl get pods > /dev/null
  if [ $? != 0 ]; then
    # Developer note: Kubectl should be included in your prereqs.yaml as a client prereq if it is required for your script.
    echo "Error executing kubectl. Verify that kubectl is installed and you are connected to a Kubernetes cluster."
    exit 1
  fi
}

# Creates the resources specified in the namespaceSetup inventory item. Optionally creates a namespace.
namespace_setup () {
  if [ -z $namespace ]; then
    echo "Error: The namespace was not specified."
    print_usage
  fi
  if ! kubectl get namespace $namespace ; then
    echo "Error: The specified namespace [$namespace] does not exist."
  fi
  set -e
  sed "s/<namespace-name>/$namespace/g" $casePath/inventory/namespaceSetup/files/rolebinding.yaml | kubectl apply -n $namespace -f  -
  sed "s/<image-pull-secret>/$pullSecretName/g" $casePath/inventory/namespaceSetup/files/service-account.yaml | kubectl apply -n $namespace -f -
  $casePath/inventory/namespaceSetup/files/scc.sh $namespace
  set +e
}

# Install the operator from the etcdOperators inventory item
install_operator () {
  # Verify that we have the expected parameters specified.
  foundError=0
  if [ -z $namespace ]; then
    echo "Error: The namespace was not specified."
    foundError=1
  fi
  if [ -z $instance ]; then
    echo "Error: The instance name was not specified."
    foundError=1
  fi
  if [ $foundError -eq 1 ]; then
    print_usage
  fi
  version=`cat $casePath/inventory/etcdOperators/resources.yaml | grep version | awk -F: {'print $2'}`
  set -e

  HELM_CSV_MEMORY_ARRAY=($(cat "${chartsFile}"))
  helm_row=${HELM_CSV_MEMORY_ARRAY[1]}
  OLDIFS=$IFS
  IFS=","
  chart_name=`echo "$helm_row" | awk -F, '{print $1}'`
  chart_version=`echo "$helm_row" | awk -F, '{print $2}'`
  IFS=$OLDIFS

  case_archive_dir="$(dirname ${chartsFile})"

  if helm version | grep "v3\." ; then
    echo "Installing etcd-operator chart using Helm 3 syntax"
    helm install "${case_archive_dir}/charts/${chart_name}-${chart_version}.tgz" --name-template $instance --namespace $namespace --version $version --set serviceAccount.create=false,serviceAccount.name=etcd-service-account,etcdOperator.image.repository=$imageReg/coreos/etcd-operator,etcdOperator.image.tag=v0.9.4-amd64,backupOperator.image.repository=$imageReg/coreos/etcd-operator,backupOperator.image.tag=v0.9.4-amd64,restoreOperator.image.repository=$imageReg/coreos/etcd-operator,restoreOperator.image.tag=v0.9.4-amd64
  else
    echo "Installing etcd-operator chart using Helm 2 syntax"
    helm install "${case_archive_dir}/charts/${chart_name}-${chart_version}.tgz" --name $instance --namespace $namespace --version $version --set serviceAccount.create=false,serviceAccount.name=etcd-service-account,etcdOperator.image.repository=$imageReg/coreos/etcd-operator,etcdOperator.image.tag=v0.9.4-amd64,backupOperator.image.repository=$imageReg/coreos/etcd-operator,backupOperator.image.tag=v0.9.4-amd64,restoreOperator.image.repository=$imageReg/coreos/etcd-operator,restoreOperator.image.tag=v0.9.4-amd64 --tls
  fi
  set +e
}

# Runs the expected commands
run_install () {
  echo "Executing installOperator"
  check_kube_connection
  namespace_setup
  install_operator
}

# Parse CLI parameters
while [ "$1" != "" ]; do
  case $1 in
      --caseJsonFile ) 
      shift
      caseJsonFile="${1}"
      ;;
      --casePath )    
      shift
      casePath="${1}"
      ;;
      --inventory )    
      shift
      inventory="${1}"
      ;;
      --action )
      shift
      action="${1}"
      ;;
      --namespace )    
      shift
      namespace="${1}"
      ;;
      --instance )
      shift
      instance="${1}"
      ;;
      --args )    
      shift
      parse_dynamic_args "${1}"
      ;;
      --help ) 
      print_usage 0
      ;;
      *)
      echo "Invalid Option ${1}" >&2
      exit 1
      ;;    
  esac
  shift
done

# Execution order
check_cli_args
run_install