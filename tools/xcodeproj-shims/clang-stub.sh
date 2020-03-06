#!/bin/bash
set -eu

while :; do
    case $1 in
        -MF)
            shift
            touch $1
            ;;
        *.o)
            break
            ;;
    esac

    shift
done
 