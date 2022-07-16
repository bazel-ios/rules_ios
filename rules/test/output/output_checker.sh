#!/bin/bash
INPUT=$PWD/%TARGET%
# Setup the test dir - for a tree artifact we need to unload the input
if [[  $INPUT  == *.ipa ]]; then
    pushd $TEST_TMPDIR
    unzip  $INPUT
    pushd Payload/*.app
elif [[  $INPUT  == *.zip ]]; then
    pushd $TEST_TMPDIR
    unzip  $INPUT
    pushd *.xctest
else
   pushd $(readlink $INPUT)
fi

STATUS=0

check_expected_output() {
    echo "TEST EXPECTED $1"
    if [[ ! -e "$1" ]]; then 
        echo "Missing output $1"
        STATUS=1
   fi
}

EXPECT=%EXPECT%
for f in ${EXPECT[@]}; do
    check_expected_output "$f"
done

check_unxpected_output() {
    echo "TEST UNEXPECTED $1"
    if [[ -e "$1" ]]; then 
        echo "Has unexpected output $1"
        STATUS=1
   fi
}

UNEXPECT=%UNEXPECT%
for f in ${UNEXPECT[@]}; do
    check_unxpected_output "$f"
done

# Dump the directory to better diagnose a failure
if [[ ! $STATUS -eq 0 ]]; then
    echo "Got directory"
    find .
fi

exit $STATUS
