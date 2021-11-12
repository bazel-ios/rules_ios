#!/bin/bash
set -e

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# This is an unarchive algorithm that deals with duplicate objects
# just extracting with ar won't do that and there isn't a great existing way
unarchive() {
    FILE="$PWD/$1"

    rm -rf *.o 

    # Assume that if unarchiving fails, it's already an object.
    # Consider writing code to check for that case
    ar -x "$FILE" || (mv "$FILE" "$FILE.o" && return)
    ar t "$FILE" | grep \.o$ | sort > objs.txt
 
    if [[ "$(cat objs.txt | uniq | /sbin/md5)" == "$(cat objs.txt | /sbin/md5)" ]]; then
       return -1
    fi

    i=0
    LAST_OBJ=""
    while IFS=\\\n read -r var; do
        OBJ="$var"
        if [[ ! "$LAST_OBJ" == "$OBJ" ]]; then
            LAST_OBJ="$OBJ"
            continue
        fi
        LAST_OBJ="$OBJ"

        (( i+=1 ))
        ar -p "$FILE" "$OBJ"  > "$i-$OBJ"

	# Note that this operation is slow, consider moving duplicates
        ar -d "$FILE" "$OBJ"
    done < objs.txt
}


# Note: this program is the simplest version of patching a static library
# Other code should handle making frameworks, etc
patch() {
     EXTDIR="$(mktemp -d "${TMPDIR:-/tmp}/bazel_m1_utils.XXXXXXXX")"
     OUTD=$PWD
     pushd $EXTDIR > /dev/null

     rm -rf "$OF.ar"

     lipo "$FWF" -thin arm64 -output "$OF.ar" || cp "$FWF" "$OF.ar"

     # If unarchive fails assume it was a single object file
     # consider better handling that case
     unarchive "$OF.ar" || true

     touch link.filelist

     # See comment in tools/m1_utils/BUILD.bazel
     ARM64_TO_SIM_PATH=$SCRIPT_DIR/arm64-to-sim 

     # Update each of the files
     for file in *.o; do
         chmod 777 "$file"

         # TODO: Versions should be input from the build system - hardcoded to 11
         "$ARM64_TO_SIM_PATH" "$file" 11 11 --obj || true
         echo "$PWD/$file" >> link.filelist
     done;
     ARGS=(xcrun libtool)
     ARGS+=(-static -arch_only arm64 -D)
     ARGS+=(-filelist link.filelist  -o $OUTD/$OF)
     export IPHONEOS_DEPLOYMENT_TARGET\=15.0
     "${ARGS[@]}"
}

# Framework file 
export FWF="$1"

# Output file
export OF="$2"

patch

