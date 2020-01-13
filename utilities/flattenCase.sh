#!/bin/sh

# Flatten the heirarchy of case files into a single YAML file
# Verify that the YAML is valid.
# Display to stdout 

# Usage:
# cd ibm-case
# ../utilities/flattenCase.sh 

YAMLINDENT="  "
INVENTORY_DIR="inventory"
CERTIFICATIONS_DIR="certifications"
CASEDIR=`pwd`
OUTFILE="$CASEDIR/case-complete-gen.yaml"

echo "# Generated CASE File" > "$OUTFILE"

yamlIndent() {
  levels=$1
  indent=""
  for ((i=1;i<=levels;i++)); do 
    indent="${indent}${YAMLINDENT}"
  done
  echo "${indent}"
}

appendToCASE() {
  IFS=''
  sectionname=$1
  file=$2
  indentlevel=$3
  echo $(yamlIndent $indentlevel)"$sectionname:" >> "$OUTFILE"
  while read -r line; do 
    nextlevel=$((indentlevel+1))
    echo $(yamlIndent $nextlevel)"${line}" >> "$OUTFILE"
  done < $file
}

appendYamlToCASE() {
  IFS=''
  sectionname=$1
  file=$2
  indentlevel=$3
  echo $(yamlIndent $indentlevel)"$sectionname:" >> "$OUTFILE"
  yq read $file $sectionname | while read -r line; do 
    nextlevel=$((indentlevel+1))
    echo $(yamlIndent $nextlevel)"${line}" >> "$OUTFILE"
  done
}

addInventoryToCASE() {
  cd $INVENTORY_DIR
  echo $(yamlIndent 1)"inventories:" >> "$OUTFILE"
  for f in *; do
    if [ -d "$f" ]; then
        # $f is a directory
        oridir=`pwd`
        #echo $f
        cd $f
        inventoryname=$f
        # inventory:
        #   <name>:
        #     inventory:
        echo $(yamlIndent 2)"$inventoryname:" >> "$OUTFILE"
        appendYamlToCASE "inventory" "inventory.yaml"  3
        appendYamlToCASE "actions" "actions.yaml" 4
        if [[ -f "resources.yaml" ]]; then
          appendYamlToCASE "resources" "resources.yaml"  4
        fi
        cd $oridir

    fi
  done
  cd $CASEDIR
}

addCertificationsToCASE() {
  cd $CERTIFICATIONS_DIR
  echo $(yamlIndent 1)"certifications:" >> "$OUTFILE"
  for f in *; do
    certname=$(echo "${f%%.*}")
    # certifiations:
    #   <name>:
    #     <certification>:
  echo $(yamlIndent 2)"$certname:" >> "$OUTFILE"
    appendYamlToCASE "certification" $f 3
  done
  cd $CASEDIR
}

echo $(yamlIndent 0)case: >> "$OUTFILE"
appendToCASE "case" "case.yaml" 1
appendYamlToCASE "roles" "roles.yaml" 1
appendYamlToCASE "prereqs" "prereqs.yaml" 1
addInventoryToCASE
addCertificationsToCASE 
