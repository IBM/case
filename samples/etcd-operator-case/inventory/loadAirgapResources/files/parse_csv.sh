#!/bin/bash

# Default arg values
CASE_ARCHIVE_DIR=""
CSV_FILE=""
ACTION=""
TO_REGISTRY=""
USAGE="
parse_csv.sh --args \"--imagesFile <image csv> --toRegistry <registry to save to>,[--caseArchiveDir <case archive offline dir>]\"
"

OC_TXT_MAP=$(mktemp /tmp/oc_image_mirror_mapping.XXXXXXXXX)

#
# ENUM for csv field locations
#
registry=0
image_name=1
tag=2
digest=3
mytype=4
os=5
arch=6
variant=7
insecure=8

#
# parse_args will parse the CLI args passed to the script
# and set the required internal variables needed.
#
parse_args() {
  # Parse CLI parameters
  while [ "$1" != "" ]; do
    case $1 in
        --casePath )
        shift
        ;;
        --instance )
        shift
        ;;
        --namespace )
        shift
        ;;
        --caseJsonFile )
        shift
        ;;
        --inventory )
        shift
        ;;
        --action )
        shift
        ACTION="${1}"
        ;;
        --args )
        shift
        parse_dynamic_args "${1}"
        ;;
        *)
        echo "Invalid Option ${1}" >&2
        exit 1
        ;;

    esac
    shift
  done
}

#
# Parses the args (--args) parameter if specified. Updates installType if specified.
parse_dynamic_args() {
  _IFS=$IFS
  IFS=" "
  read -ra arr <<< "${1}"
  IFS="$_IFS"
  arr+=("")
  idx=0
  v="${arr[${idx}]}"

  while [ "$v" != "" ]; do
    case $v in
      --imagesFile)
      idx=$(( idx + 1 ))
      v="${arr[${idx}]}"
      CSV_FILE="${v}"
      ;;
      --toRegistry)
      idx=$(( idx + 1 ))
      v="${arr[${idx}]}"
      TO_REGISTRY="${v}"
      ;;
      --caseArchiveDir)
      idx=$(( idx + 1 ))
      v="${arr[${idx}]}"
      CASE_ARCHIVE_DIR="${v}"
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
}

#
# print_usage prints usage menu and exits with $1
#
print_usage() {
  echo "[ Usage: ${USAGE}"
  exit "${1}"
}

#
# parse_case_image_csv turns the image CSV file into newline separated array
# held in memory to be used by other functions later.
#
IMAGE_CSV_MEMORY_ARRAY=
parse_case_image_csv() {
  _IFS=$IFS
  IFS=$'\r\n'
  IMAGE_CSV_MEMORY_ARRAY=($(cat "${CSV_FILE}"))
  IFS=$_IFS
}

#
# parse_case_image_csv_for_field example function for how to parse all fields of
# the CSV file out
#
parse_case_image_csv_for_field() {
  _IFS=$IFS
  field="${1}"

  if [[ -z "${field}" ]]; then field="${registry}"; fi

  idx=1
  while [[ idx -ne ${#IMAGE_CSV_MEMORY_ARRAY[@]} ]]; do
    line=${IMAGE_CSV_MEMORY_ARRAY[${idx}]}
    IFS=','
    read -ra split_line <<< "${line}"
    echo ${split_line[${field}]}

    idx=$(( idx + 1 ))
  done
  IFS=$_IFS
}

#
# parse_case_image_csv_for_field_with_index example function for how to get a specific
# field from a specific line in the CSV
#
parse_case_image_csv_for_field_with_index() {
  field="${1}"
  idx="${2}"

  if [[ -z "${field}" ]]; then field="${registry}"; fi
  if [[ -z "${idx}" ]]; then idx=0; fi

  line=${IMAGE_CSV_MEMORY_ARRAY[${idx}]}
  _IFS=$IFS
  IFS=','
  read -ra split_line <<< "${line}"
  echo ${split_line[${field}]}
  IFS=$_IFS
}

#
# example_download_using_docker will download all the images in the CSV using
# docker and your local docker config.
#
example_download_using_docker() {
  len=${#IMAGE_CSV_MEMORY_ARRAY[@]}
  idx=0
  _IFS=$IFS
  IFS=':'
  read -ra split_creds <<< "${SOURCE_REPOSITORY_CREDENTIALS}"

  docker_u="${split_creds[0]}"
  docker_p="${split_creds[1]}"

  # Any other docker config info will go here as well

  docker login -u "$docker_u" -p "$docker_p"

  while [[ idx -ne len ]]
  do
    line=${IMAGE_CSV_MEMORY_ARRAY[${idx}]}
    IFS=','
    read -ra split_line <<< "${line}"

    source_registry="${split_line[${registry}]}"
    source_image_name="${split_line[${image_name}]}"
    source_tag="${split_line[${tag}]}"
    source_arch="${split_line[${arch}]}"
    source_digest="${split_line[${digest}]}"  # Optional

    if [[ -z "$source_digest" ]]
    then
      docker pull "${source_registry}/${source_image_name}@${source_digest}"
    else
      docker pull "${source_registry}/${source_image_name}:${source_tag}"
    fi

    idx=$(( idx + 1 ))
  done
  IFS=$_IFS
}

#
# example_oc_image_mirror will mirror images in the CSV file to a hosted
# registry, using oc mirror image command
#
example_oc_image_mirror() {
  _IFS=$IFS
  len=${#IMAGE_CSV_MEMORY_ARRAY[@]}
  idx=1

  while [[ idx -ne len ]]
  do
    line=${IMAGE_CSV_MEMORY_ARRAY[${idx}]}
    IFS=','
    read -ra split_line <<< "${line}"

    source_registry="${split_line[${registry}]}"
    source_image_name="${split_line[${image_name}]}"
    source_tag="${split_line[${tag}]}"
    source_arch="${split_line[${arch}]}"
    source_digest="${split_line[${digest}]}"

    dest_string="${TO_REGISTRY}/${source_image_name}:${source_tag}"

    echo "${source_registry}/${source_image_name}@${source_digest}=$dest_string" >> "$OC_TXT_MAP"

    idx=$(( idx + 1 ))
  done
  IFS=$_IFS
}

#
# example_skopeo will copy images in the CSV file to a hosted
# registry, using skopeo copy command
#
example_skopeo() {
  _IFS=$IFS
  len=${#IMAGE_CSV_MEMORY_ARRAY[@]}
  idx=1
  s_rc=0

  while [[ idx -ne len ]]
  do
    line=${IMAGE_CSV_MEMORY_ARRAY[${idx}]}
    IFS=','
    read -ra split_line <<< "${line}"

    source_registry="${split_line[${registry}]}"
    source_image_name="${split_line[${image_name}]}"
    source_tag="${split_line[${tag}]}"
    source_arch="${split_line[${arch}]}"
    source_digest="${split_line[${digest}]}"

    dest_string="docker://${TO_REGISTRY}/${source_image_name}:${source_tag}"

    skopeo copy \
          "docker://${source_registry}/${source_image_name}@${source_digest}" \
          "$dest_string" \
          "--all"

    if [[ "$rc" -ne 0 ]]; then
      s_rc=11
    fi

    idx=$(( idx + 1 ))
  done
  IFS=$_IFS
  return s_rc
}

#
# example_parse_all_oc_image_mirror is an example of parsing the image
# CSV and using oc mirror to transfer the images to an internal repository
#
example_parse_all_oc_image_mirror() {
  touch "$OC_TXT_MAP"

  if  [[ -z "${CSV_FILE}" ]]
  then
    for fname in ${CASE_ARCHIVE_DIR}/*-images.csv; do
      CSV_FILE="$fname"
      parse_case_image_csv
      example_oc_image_mirror
    done
  else
    parse_case_image_csv
    example_oc_image_mirror
  fi

  oc image mirror --filter-by-os '.' -f "$OC_TXT_MAP" --max-per-registry 1 --insecure
  o_rc="$?"
  rm -f "$OC_TXT_MAP"
  if [[ "$o_rc" -ne 0 ]]; then
    exit 11
  fi

}

#
# example_parse_all_skopeo_copy is an example of parsing the image
# CSV and using skopeo copy to transfer the images to an internal repository
#
example_parse_all_skopeo_copy() {
  if  [[ -z "${CSV_FILE}" ]]
  then
    for fname in "${CASE_ARCHIVE_DIR}"/*-images.csv; do
      CSV_FILE="$fname"
      parse_case_image_csv
      example_skopeo
      rc="$?"
    done
  else
    parse_case_image_csv
    example_skopeo
    rc="$?"
  fi

  if [[ "$rc" -ne 0 ]]; then
    exit 11
  fi
}

#
# example_main_entry_point provides an example flow for
# an end to end scenario launched from the CASE launcher
# provided by cloudctl.
#
example_main_entry_point() {
  case "$ACTION" in
    skopeoCopy)
    echo "Using skopeo copy"
    example_parse_all_skopeo_copy
    ;;
    ocMirror)
    echo "Using oc image mirror"
    example_parse_all_oc_image_mirror
    ;;
    *)
    echo "Action: $ACTION not supported at this time"
    ;;
  esac
}

parse_args "$@"

echo -en "\033[0;36mParsing the image CSV file located at: \033[0m"
if [[ -z "${CSV_FILE}" ]]
then
  echo "imagesFile not set, defaulting to all image CSV files"
else
  echo "${CSV_FILE}"
fi

example_main_entry_point