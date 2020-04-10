#!/bin/bash

# Copies the xcodeproject from the bazel output directory to the BAZEL_WORKSPACE directory when ran
set -euo pipefail
readonly project_path="${PWD}/$(project_short_path)"
readonly dest="${BUILD_WORKSPACE_DIRECTORY}/$(project_short_path)/"
readonly tmp_dest=$(mktemp -d)/$(project_full_path)/

readonly stubs_dir="${dest}/bazelstubs"
mkdir -p "${stubs_dir}"

readonly installer="$(installer_short_path)"

installer_dir=$(dirname "${stubs_dir}/${installer}")
mkdir -p "${installer_dir}"
cp "${installer}" "${stubs_dir}/${installer}"
cp "$(clang_stub_short_path)" "${stubs_dir}/clang-stub"
cp "$(clang_stub_ld_path)" "${stubs_dir}/ld-stub"
cp "$(clang_stub_swiftc_path)" "${stubs_dir}/swiftc-stub"

rm -fr "${tmp_dest}"
mkdir -p "$(dirname $tmp_dest)"
cp -r "${project_path}" "$tmp_dest"
chmod -R +w "${tmp_dest}"

# always trim three ../ from path, since that's "bazel-out/darwin-fastbuild/bin"
sed -i.bak -E -e 's|([ "])../../../|\1|g' "${tmp_dest}/project.pbxproj"
rm "${tmp_dest}/project.pbxproj.bak"
rsync --recursive --quiet --copy-links "${tmp_dest}" "${dest}"
mv dummy-testhostapp-plists $dest
