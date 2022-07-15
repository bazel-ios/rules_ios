#!/bin/bash

set -ex

## ios_vmd_test_runner.template.sh -> ios_vm_test_runner.sh -> vm_runner.sh

file $TEST_SRCDIR
rm -rf /tmp/RUNNER_UPLOAD.tar

tar cfh /tmp/RUNNER_UPLOAD.tar $TEST_BUNDLE_TMP_DIR 
tar rfh /tmp/RUNNER_UPLOAD.tar $TEST_HOST_TMP_DIR

## Pack runfiles
pushd $TEST_SRCDIR 
tar rfh /tmp/RUNNER_UPLOAD.tar .
popd

pushd $PYTHON_RUNFILES
tar rfh /tmp/RUNNER_UPLOAD.tar .
popd

cp /tmp/RUNNER_UPLOAD.tar .

export UPLOAD=RUNNER_UPLOAD.tar

## FIXME - move this into the VM runner
test -f $UPLOAD || (echo "MISS UPLOAD $UPLOAD" && exit 1)

## This runs on the host
tools/vmd/vmd "TEST_UNDECLARED_OUTPUTS_DIR='' build_bazel_rules_ios/external/xctestrunner/ios_test_runner $@"
