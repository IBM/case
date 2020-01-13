#!/bin/bash
#
# Use this script to apply the Security Context Constraint (SCC)
# Created in the clusterSetup inventory item
#

namespace=$1

if [[ "$#" -ne 1 ]] || [[ -z ${namespace} ]]; then
    echo "Usage: ./scc.sh <namespace>"
    exit 1
fi

oc adm policy add-scc-to-group ibm-restricted-scc-etcd system:serviceaccounts:$namespace