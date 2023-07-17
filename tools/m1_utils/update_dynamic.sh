set -e

# Note: this program is the simplest version of patching a dynamic library
# Other code should handle making frameworks, etc
patch() {
    EXTDIR="$(mktemp -d "${TMPDIR:-/tmp}/bazel_m1_utils.XXXXXXXX")"
    pushd $EXTDIR > /dev/null
    trap "rm -rf $EXTDIR" EXIT

    # Attempt lipo if it's a fat binary
    ARCHS=()
    while read ARCH; do
        ARCHS+=($ARCH)
    done < <(lipo -archs "$FWF")
    if test "${#ARCHS[@]}" -gt 1; then
        lipo "$FWF" -thin arm64 -output "OF.ar" || cp "$FWF" "OF.ar"
    else
        cp "$FWF" "OF.ar"
    fi

    # FIXME: Versions should be input from the build system
    # filter stderr to ignore code signature warnings
    xcrun vtool -arch arm64 -set-build-version 7 11.0 11.0 -replace -output "$OF" "OF.ar" \
        2> >(grep --invert 'warning: code signature will be invalid' >&2)

    # Xcode 13.1-13.2.1 workaround - see update_static.sh
    # filter stderr to ignore code signature warnings
    strip -S "$OF" \
        2> >(grep --invert 'warning: changes being made to the file will invalidate the code signature' >&2)
}

# Framework file
export FWF="$1"

# Output file
export OF="$2"

patch
