#!/bin/bash

#
# Installs the ectd-operator-case
# Usage: install.sh [--caseJsonFile casejsonpath --inventory inventoryItemOfLauncher --action launchAction] 
#                    --args args --casePath casepath --instance instancename --namespace namespace
# 
# The additional args parameters include: imageRegistry, imageRegistryUser, imageRegistryPass, and pullSecretName
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
helmCSV=""
regUser=""
regPass=""
imageReg=""
pullSecretName=""



print_usage () {
  echo "usage: install.sh [--caseJsonFile casejsonpath --inventory inventoryItemOfLauncher --action launchAction] --args \"--imageRegistry imageRegistry, --imageRegistryUser user, --imageRegistryPass pass, --pullSecretName secretName\" --casePath casepath --instance instancename --namespace namespace"
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
      createNamespace="${v}"
      ;;
      --imageRegistry)
      idx=$(( idx + 1 ))
      v="${arr[${idx}]}"
      imageReg="${v}"
      ;;
      --imageRegistryUser)
      idx=$(( idx + 1 ))
      v="${arr[${idx}]}"
      regUser="${v}"
      ;;
      --imageRegistryPass)
      idx=$(( idx + 1 ))
      v="${arr[${idx}]}"
      regPass="${v}"
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

  # Check that all required parameters have been specified
  foundError=0
  if [ -z $imageReg ]; then
    echo "Error: The imageRegistry parameter was not specified with the --args parameter."
    foundError=1
  fi
  if [ -z $regUser ]; then
    echo "Error: The imageRepoUser parameter was not specified with the --args parameter."
    foundError=1
  fi
  if [ -z $regPass ]; then
    echo "Error: The imageRegistryPass parameter was not specified with the --args parameter."
    foundError=1
  fi
  if [ -z $pullSecretName ]; then
    echo "Error: The pullSecretName parameter was not specified with the --args parameter."
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

create_namespace () {
  if [ -z $namespace ]; then
    echo "Error: The namespace was not specified."
    print_usage
  fi
  set -e
  sed "s/<namespace-name>/$namespace/g" $casePath/inventory/namespaceSetup/files/namespace.yaml | kubectl apply -f -
  set +e
}

# Creates the resources specified in the clusterSetup inventory item
cluster_setup () {
  echo "In cluster_setup"
  check_kube_connection
  isOCP=0
  if kubectl api-resources | grep securitycontextconstraints > /dev/null ; then
    isOCP=1
  fi
  set -e
  for clusterYaml in $casePath/inventory/clusterSetup/files/etcd-resources/*.yaml; do
    if [[ $clusterYaml == *-scc.yaml ]]; then
      if [ $isOCP -eq 1 ]; then
        echo "applying $clusterYaml"
        kubectl apply --validate=false -f $clusterYaml
      fi
    elif [[ $clusterYaml == *psp* ]]; then
      if [ $isOCP -ne 1 ]; then
        echo "applying $clusterYaml"
        kubectl apply -f $clusterYaml
      fi
    elif [[ $clusterYaml != */etcdclusters-crd.yaml ]]; then
      echo "applying $clusterYaml"
      kubectl apply -f $clusterYaml
    fi
    
  done
  set +e
  if kubectl get secrets $pullSecretName -n $namespace > /dev/null 2>&1 ; then
    kubectl create secret docker-registry $pullSecretName --docker-server=$imageReg --docker-username=$regUser --docker-password=$regPass --docker-email=$regUser -n $namespace --dry-run -o yaml | kubectl apply -f -
  else
    kubectl create secret docker-registry $pullSecretName --docker-server=$imageReg --docker-username=$regUser --docker-password=$regPass --docker-email=$regUser -n $namespace
  fi
}

# Runs the expected commands
run_install () {
  echo "Executing clusterSetup"
  if [ $createNamespace -eq 1 ]; then
    create_namespace
  fi
  cluster_setup
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