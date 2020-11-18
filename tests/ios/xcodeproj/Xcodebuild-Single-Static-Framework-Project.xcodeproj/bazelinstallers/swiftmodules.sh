#!/bin/bash

set -euo pipefail

# Copy Bazel build `.swiftmodule` files to `DerivedData`. This is used by Xcode
# and its indexing.
echo "Start copying swiftmodules at `date`"
FOUND_SWIFTMODULES=`grep -A 2 primary_output "$BAZEL_BUILD_EVENT_TEXT_FILENAME" | grep -w uri | grep "\.swiftmodule" | sed "s/uri: \"file:\/\///" || true`
if [[ -z $FOUND_SWIFTMODULES ]]; then 
    echo "No swiftmodules found, finished at `date`"
    exit 0
fi
declare -a EXISTING_SWIFTMODULES=()
for i in $FOUND_SWIFTMODULES
do
  if [[ -f $i ]]
  then
    EXISTING_SWIFTMODULES+=($i)
  fi
done
echo "Found ${#EXISTING_SWIFTMODULES[@]} existing SWIFTMODULES"
if [ ${#EXISTING_SWIFTMODULES[@]} -ne 0 ]
then
  "$BAZEL_INSTALLERS_DIR/_swiftmodule.sh" ${EXISTING_SWIFTMODULES[*]}
else
  echo "No SWIFTMODULES found"
fi
echo "Finish copying swiftmodules at `date`"
