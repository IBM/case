#!/bin/sh

# Create a CASE archive from a CASE directory such that the SHA digest of the archive is consistent.

# Usage:
# createArchive.sh <case-directory>

if [ "$#" -lt 1 ]; then
	echo "Usage: createArchive.sh <CASE-DIRECTORY>"
  exit 1
fi

if ! type yq >/dev/null 2>&1; then
  echo 'Error: yq is not installed.'
  exit 1
fi

CASEDIR=$1

CASENAME=$(yq r $CASEDIR/case.yaml name)
CASEVERSION=$(yq r $CASEDIR/case.yaml version)

CURDIR=$(pwd)
cd $CASEDIR/..

# tar + gz the file.  Use the -n option to avoid adding a timestamp.
ARCHIVENAME="$CASENAME-$CASEVERSION.tgz"
tar -cf - -C "$CASEDIR/.." "$CASENAME/" | gzip -nc > "$CURDIR/$ARCHIVENAME"

#Display teh SHA
if type shasum >/dev/null 2>&1; then
  shasum -a 256 "$CURDIR/$ARCHIVENAME" | cut -f1 -d' '
fi

cd $CURDIR
