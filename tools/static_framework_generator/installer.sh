#!/bin/bash
#
# A script to copy a file from the bazel cache to the bazel workspace
# In order for this to work, sandboxing has to be disabled
#
# The BUILD_WORKSPACE_DIRECTORY env variable is automatically injected by bazel when 
# doing `bazel run`. See: https://docs.bazel.build/versions/master/user-manual.html#run
#
# But if this rule is executed doing `bazel test`, the BUILD_WORKSPACE_DIRECTORY
# is not automatically injected by bazel, and instead it should be passed from 
# command line when running bazel. For example:
# ```
# bazel test --test_env=BUILD_WORKSPACE_DIRECTORY="$(PWD)" <YOUR_TARGET_HERE>
# ```
#

set -euo pipefail

if [ -z ${BUILD_WORKSPACE_DIRECTORY+x} ]; then
    echo 'The BUILD_WORKSPACE_DIRECTORY environmental variable is not set.
If you are running this rule as a test type, you need to inject the BUILD_WORKSPACE_DIRECTORY
environmental variable manually. For example:
> bazel test --test_env=BUILD_WORKSPACE_DIRECTORY="$(PWD)" <YOUR_TARGET_HERE>
'
    exit 1
fi

destination_path="${BUILD_WORKSPACE_DIRECTORY}/$(destination)"

mkdir -p "${destination_path}"
for file in $(files); do
    full_file_path="${BUILD_WORKSPACE_DIRECTORY}/${file}"
    cp -crf "${full_file_path}" "${destination_path}"
done

# Since we are extracting files from the Bazel cache, they may be read-only.
# Change that by adding write permissions
chmod -R +w "${destination_path}"
