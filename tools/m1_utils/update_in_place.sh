#!/bin/bash
set -e

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# INPUT="$(realpath "$1")"
INPUT="$PWD/$1"
OF="$(basename "$INPUT").tmp"
if file $INPUT | grep -q dynamic; then
   echo update_dynamic "$INPUT"
   $SCRIPT_DIR/update_dynamic.sh "$INPUT" "$OF"
   mv $OF $INPUT
else
   echo update_static "$INPUT"
   $SCRIPT_DIR/update_static.sh "$INPUT" "$OF"
   mv "$OF" "$INPUT"
fi

