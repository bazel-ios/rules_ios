#!/bin/bash
set -eu

original_args=("$@")

while :; do
    test $# -eq 0 && exit 0
    case $1 in
        -V)
            # Xcode 15+ needs to know the version of libtool
            exec libtool "${original_args[@]}"
            ;;
        *.dat)
            # provides the header for an empty .dat file
            echo -n -e '\x00lld\0' > $1
            ;;
        *)
            ;;
    esac

    shift
done
