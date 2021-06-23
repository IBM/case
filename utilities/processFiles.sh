#!/usr/bin/env bash

PROGNAME=$(basename "$0")
USAGE="Usage: $PROGNAME (-s | --source_dir) <source dir> (-d | --destination_dir) <destination dir> (-h | --help)

This script will recursively iterate over files and folders and create a resources.yaml
with the resources.resourceDefs.files filled in with an entry for each file.

OPTIONS:
-s,--source_dir      Source files directory (error if not a files directory)
-d,--destination_dir Target directory for output
-h,--help            Display this message
"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--source_dir)
        SOURCE="$2"
        shift # past argument
        shift # past value
        ;;
        -d|--destination_dir)
        DESTINATION="$2"
        shift # past argument
        shift # past value
        ;;
        -h|--help)
        echo "$USAGE"
        exit 0
        ;;
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done

if [[ -z "${SOURCE}" || -z "${DESTINATION}" ]]; then
    echo "Incorrect arguments."
    echo "${USAGE}"
    exit 1
fi

if [[ ! -d "${SOURCE}" ]]; then
    echo "source_dir argument is not a directory"
    exit 1
fi

if [[ ! -d "${DESTINATION}" ]]; then
    echo "destination_dir argument is not a directory"
    exit 1
fi

if ! SOURCE_FULL_PATH=$(cd "${SOURCE}" >/dev/null || exit; echo "${PWD}"); then
    echo "An error occurred accessing source_dir argument ${SOURCE}"
    exit 1
fi

if [[ $(basename -- "${SOURCE_FULL_PATH}") != "files" ]]; then
    echo "source_dir argument should be a CASE files directory"
    exit 1
fi

# Writes out header for ${DESTINATION} file
function write_header() {
    cat << EOF > "${DESTINATION}"/resources.yaml
resources:
  metadata:
    name: "CHANGE ME"
  resourceDefs:
    files:
EOF
}

# Scans through the provided file list and write output to ${DESTINATION} file, overwriting any previous data
# Args: FILES - a return separated list of files
# Returns 0 if success
# Returns 1 if failure
function scan_files_and_write_output() {
    # A return separated list of files
    local FILES=$1
    # the default filetype
    local INITIAL_FILETYPE
    # the potentially overridden filetype
    local FINAL_FILETYPE
    # overwrite file with preliminary data and bail out if this fails
    if ! write_header; then
        echo "Unable to write header"
        return 1
    fi
    # iterate over each line
    while read -r line; do
        echo "... $line ..."
        # get the mimetype for the file and adjust it for any known filetypes
        if INITIAL_FILETYPE=$(file -b -L --mime-type "${line}"); then
            if [[ ${INITIAL_FILETYPE} == "text/plain" && $(basename -- "${line}") == manifest.yaml ]]; then
                FINAL_FILETYPE="application/vnd.case.resource.image.manifest.v1"
            elif [[ ( ${INITIAL_FILETYPE} == "text/plain" || ${INITIAL_FILETYPE} == "inode/x-empty" ) && $(basename -- "${line}") == *.yaml ]]; then
                FINAL_FILETYPE="application/vnd.case.resource.k8s.v1+yaml"
            elif [[ ${INITIAL_FILETYPE} == text/* && $(basename -- "${line}") == launch.sh ]]; then 
                FINAL_FILETYPE="application/vnd.case.resource.script.bash.v1+launcher" 
            elif [[ ${INITIAL_FILETYPE} == text/* && $(basename -- "${line}") == *.sh ]]; then 
                FINAL_FILETYPE="application/vnd.case.resource.script.bash.v1"
            else
                FINAL_FILETYPE="${INITIAL_FILETYPE}"
            fi
        fi
        cat << EOF >> "${DESTINATION}"/resources.yaml
    - mediaType: ${FINAL_FILETYPE}
      ref: ${line#$SOURCE_FULL_PATH/}
EOF
    done <<< "${FILES}"
}

# starting point for this script
function main() {
    # use find to dereference any symbolic links and report any files it finds
    if ! FILES=$(find -L "${SOURCE_FULL_PATH}" -name "*" -type f 2>/dev/null | grep '.' | sort); then
        echo "No files found. Exting without generating a file."
        return 1
    fi

    # does destination file exist?
    if [ -w "${DESTINATION}"/resources.yaml ]; then
        echo "File exists. Overwrite? y/n"
        read -r ANSWER
        case $ANSWER in 
            [yY] ) scan_files_and_write_output "${FILES}" ;;
            [nN] ) echo "Exiting without making changes" ;;
        esac
    else
        # destination file doesn't exist or no write permission granted
        scan_files_and_write_output "${FILES}"
    fi
}

main
