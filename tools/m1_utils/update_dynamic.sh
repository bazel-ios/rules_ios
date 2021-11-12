set -e

# Note: this program is the simplest version of patching a dynamic library
# Other code should handle making frameworks, etc
patch() {
     EXTDIR="$(mktemp -d "${TMPDIR:-/tmp}/bazel_m1_utils.XXXXXXXX")"
     OUTD="$PWD"
     pushd $EXTDIR > /dev/null
     lipo "$FWF" -thin arm64 -output "$OF.ar" || cp "$FWF" "$OF.ar"

     # FIXME: Versions should be input from the build system
     xcrun vtool -arch arm64 -set-build-version 7 11.0 11.0 -replace -output "$OUTD/$OF" "$OF.ar"
}

# Framework file 
export FWF="$1"

# Output file
export OF="$2"

patch
