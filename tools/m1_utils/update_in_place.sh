#!/bin/bash
set -e

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

INPUT="$PWD/$1"

# TODO - verify mutli-processing edge case with Bazel
OF="$(basename "$INPUT").tmp"
if file $INPUT | grep -q dynamic; then
   $SCRIPT_DIR/update_dynamic.sh "$INPUT" "$OF"
   mv $OF $INPUT
else
   $SCRIPT_DIR/update_static.sh "$INPUT" "$OF"
   mv "$OF" "$INPUT"
fi

