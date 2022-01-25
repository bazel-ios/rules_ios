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
    ar -x "$FILE" 
    ar t "$FILE" | grep \.o$ | sort > objs.txt

    # Assume default extraction strategy is OK if no dupes
    if [[ -z "$(uniq -d objs.txt)" ]]; then
       return 0
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
     pushd $EXTDIR > /dev/null

     # Attempt lipo if it's a fat binary
     ARCHS=()
     mkdir -p "$(dirname $OF)"
     while read ARCH; do
          ARCHS+=($ARCH)
     done < <(lipo -archs "$FWF")
     if test "${#ARCHS[@]}" -gt 1; then 
         lipo "$FWF" -thin arm64 -output "OF.ar" || cp "$FWF" "OF.ar"
     else
         cp "$FWF" "OF.ar"
     fi

     # Don't unarchive a 64-bit object arm64
     FILE="OF.ar"
     if file "$FILE" | grep -q "64-bit object arm64"; then
         mv "$FILE" "$FILE.o"
     else
         unarchive "OF.ar"
     fi

     touch link.filelist

     # See comment in tools/m1_utils/BUILD.bazel
     ARM64_TO_SIM_PATH=$SCRIPT_DIR/arm64-to-sim 

     # Update each of the files
     for file in *.o; do
         chmod 777 "$file"
         # Test if the LC_BUILD_VERSION is 24, e.g. we already gave it an m1 arm64
         # object and exit
         if otool -l "$file" | grep -q LC_BUILD_VERSION; then
            cp "$FWF" "$OF"

            exit 0
         elif ! "$ARM64_TO_SIM_PATH" "$file" 11 11 --obj; then 
             # TODO: Versions should be input from the build system - hardcoded to 11
             cp "$FWF" "$OF"

             # This also allows gracefully failing on non-PIC code to include
             # special Apple LD flag and un-knowing frameworks. Consider
             # removing this once there is a way to test for latter condition.
             # We should also provide a way to use the secret "linker flag" to
             # allow the link to work
             echo "warning: falling back to input for $(basename $OF)"
             exit 0
         fi
         echo "$file" >> link.filelist
     done;
     ARGS=(xcrun libtool)
     ARGS+=(-static -arch_only arm64 -D)
     ARGS+=(-filelist link.filelist  -o $OF)
     export IPHONEOS_DEPLOYMENT_TARGET\=15.0
     "${ARGS[@]}"
}

# Framework file 
export FWF="$1"

# Output file
export OF="$2"

patch

