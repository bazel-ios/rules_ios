#!/usr/bin/env bash
# This is a helper program for the testing system  - not something you'd run directly
set -euo pipefail

source tests/wrapped_bazelisk.sh

## split tests
test_suite_count=$(wrapped_bazelisk query 'kind("test_suite", //tests/ios/unit-test:SplitTests)' | wc -l | xargs)
if [[ "$test_suite_count" != "1" ]]; then
  echo "Expected 1 test suite for split tests got $test_suite_count"
  exit 1
fi

tests_count=$(wrapped_bazelisk query 'tests(kind("test_suite", //tests/ios/unit-test:SplitTests))' | wc -l | xargs)
if [[ "$tests_count" != "2" ]]; then
  echo "More than 2 tests for split tests got $tests_count"
  exit 1
fi
