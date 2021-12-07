#!/bin/bash

set -euo pipefail

# "catch exit status 1" grep wrapper
# https://stackoverflow.com/a/49627999
c1grep() { grep "$@" || test $? = 1; }

# See `_indexstore.sh` for full details.

echo "Start remapping index files at `date`"

FOUND_INDEXSTORES=`c1grep -o 'command_line: "\(.*\.indexstore\)' $BAZEL_BUILD_EVENT_TEXT_FILENAME | sed 's/.*command_line: "//' | uniq`

declare -a EXISTING_INDEXSTORES=()
for i in $FOUND_INDEXSTORES
do
  if [ -d $i ]
  then
    EXISTING_INDEXSTORES+=($i)
  fi
done

echo "Found ${#EXISTING_INDEXSTORES[@]} existing indexstores"

if [ ${#EXISTING_INDEXSTORES[@]} -ne 0 ]
then
  "$BAZEL_INSTALLERS_DIR/_indexstore.sh" ${EXISTING_INDEXSTORES[*]}
else
  echo "No indexstores found"
fi

echo "Finish remapping index files at `date`"

ls -ltR $BUILD_DIR/../../Index/DataStore/ > $BAZEL_DIAGNOSTICS_DIR/indexstores-contents-$DATE_SUFFIX.log
