#!/bin/bash

set -euo pipefail

# See `_indexstore.sh` for full details.

echo "Start remapping index files at `date`"

FOUND_INDEXSTORES=`grep -o 'command_line: "\(.*\.indexstore\)\|command_line: "\(.*_global_index_store\)' $BAZEL_BUILD_EVENT_TEXT_FILENAME | sed 's/.*command_line: "//' | sed 's/-Xwrapped-swift=-global-index-store-import-path=//' | sort | uniq` || true

declare -a EXISTING_INDEXSTORES=()
for i in $FOUND_INDEXSTORES
do
  # Ensure 'units' and 'records' directories exist before calling index-import
  # otherwise the process could be interrupet before all index stores are imported
  #
  # Still not clear why but I've found some instances where the 'records' folder wouldn't be present after a build
  UNITS="$(find $i -type d -name 'units')"
  RECORDS="$(find $i -type d -name 'records')"
  if [ -d $i ] && [ "$UNITS" != "" ] && [ "$RECORDS" != "" ]
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

ls -ltR $INDEX_DATA_STORE_DIR/ > $BAZEL_DIAGNOSTICS_DIR/indexstores-contents-$DATE_SUFFIX.log
