#!/bin/bash
set -eu

# Xcode's stdout logging shows `swiftc -v` being called to determine its
# version. Passthrough those invocation to `swiftc`.
if [[ $# -eq 1 && $1 == "-v" ]]; then
    exec swiftc -v
fi

# Source of json-util: https://github.com/dominictarr/JSON.sh
write_output_files() {
    cat $1 | $(dirname "$0")/json-util -b -n  | sed 's/\[.*\]//' | xargs touch
}

while :; do
    test $# -eq 0 && exit 0
    case $1 in
        -output-file-map)
            shift
            write_output_files $1
            ;;
        -emit-module-path)
            shift
            touch $1
            touch ${1%.swiftmodule}.swiftdoc
            ;;
        *)
            ;;
    esac

    shift
done
 
