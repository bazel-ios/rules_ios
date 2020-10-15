#!/bin/bash

# Copies the xcodeproject from the bazel output directory to the BAZEL_WORKSPACE directory when ran
set -euo pipefail
readonly project_path="${PWD}/$(project_short_path)"
readonly dest="${BUILD_WORKSPACE_DIRECTORY}/$(project_short_path)/"
readonly tmp_dest=$(mktemp -d)/$(project_full_path)/

readonly installer="$(installer_short_path)"

rm -fr "${tmp_dest}"
mkdir -p "$(dirname $tmp_dest)"
cp -r "${project_path}" "$tmp_dest"
chmod -R +w "${tmp_dest}"

readonly stubs_dir="${tmp_dest}/bazelstubs"
mkdir -p "${stubs_dir}"

readonly installers_dir="${tmp_dest}/bazelinstallers"
mkdir -p "${installers_dir}"

readonly print_json_installers_dir="${stubs_dir}/print_json_leaf_nodes.runfiles/"
mkdir -p "${print_json_installers_dir}"

for PRINT_INSTALLER_PATH in $(print_json_leaf_nodes_runfiles)
do
  mkdir -p "${print_json_installers_dir}/$(dirname $PRINT_INSTALLER_PATH)"
  cp "${PWD}/../$PRINT_INSTALLER_PATH" "${print_json_installers_dir}/$PRINT_INSTALLER_PATH"
done

for INSTALLER_PATH in $(installer_runfile_short_paths)
do
  cp "$INSTALLER_PATH" "${installers_dir}/"
done
cp "$(installer_short_path)" "${installers_dir}/"

cp "$(clang_stub_short_path)" "${stubs_dir}/clang-stub"
cp "$(clang_stub_ld_path)" "${stubs_dir}/ld-stub"
cp "$(clang_stub_swiftc_path)" "${stubs_dir}/swiftc-stub"
cp "$(index_import_short_path)" "${installers_dir}/index-import"
cp "$(print_json_leaf_nodes_path)" "${stubs_dir}/print_json_leaf_nodes"
cp "$(infoplist_stub)" "${stubs_dir}/Info-stub.plist"
cp "$(build_wrapper_path)" "${stubs_dir}/build-wrapper"
cp "$(output_processor_path)" "${stubs_dir}/output-processor.rb"

# The new build system leaves a subdirectory called XCBuildData in the DerivedData directory which causes incremental build and test attempts to fail at launch time.
# The error message says "Cannot attach to pid." This error seems to happen in the Xcode IDE, not when the project is tested from the xcodebuild command.
# Therefore, we force xcode to use the legacy build system by adding the contents of WorkspaceSettings.xcsettings to the generated project.
# mkdir -p "$tmp_dest/project.xcworkspace/xcshareddata/"
# cp "$(workspacesettings_xcsettings_short_path)" "$tmp_dest/project.xcworkspace/xcshareddata/"
# cp "$(ideworkspacechecks_plist_short_path)" "$tmp_dest/project.xcworkspace/xcshareddata/"

chmod -R +w "${tmp_dest}"

# if installing into the root of the workspace, remove the path entry entirely
sed -i.bak -E -e 's|^([[:space:]]*path = )../../..;$|\1.;|g' "${tmp_dest}/project.pbxproj"
# always trim three ../ from path, since that's "bazel-out/darwin-fastbuild/bin"
sed -i.bak -E -e 's|([ "])../../../|\1|g' "${tmp_dest}/project.pbxproj"
rm "${tmp_dest}/project.pbxproj.bak"

rsync --recursive --quiet --copy-links "${tmp_dest}" "${dest}"
