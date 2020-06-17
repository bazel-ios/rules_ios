#!/bin/bash

set -euo pipefail

# See `_indexstore.sh` for full details.

echo "Start remapping index files at `date`"

FOUND_INDEXSTORES=`pcregrep -o1 'command_line: "(.*\.indexstore)' $bazel_build_event_text_filename || true`
declare -a EXISTING_INDEXSTORES=()
for i in $FOUND_INDEXSTORES
do
if [ -d $i ]
then
EXISTING_INDEXSTORES+=($i)
fi
done

if [ ${#EXISTING_INDEXSTORES[@]} -ne 0 ]
then
  "$BAZEL_INSTALLERS_DIR/_indexstore.sh" $EXISTING_INDEXSTORES
else
  echo "No indexstores found"
fi

echo "Finish remapping index files at `date`"
