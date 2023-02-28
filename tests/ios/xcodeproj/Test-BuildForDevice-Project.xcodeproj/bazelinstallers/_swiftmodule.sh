#!/bin/bash

set -euo pipefail

# Xcode 12 and under stored index information in /DerivedData/<project>/Build/Products
readonly xcode_12_index_dir="$BUILT_PRODUCTS_DIR"

# Xcode 13 and later store index information in /DerivedData/<project>/Index/Build/Products
readonly xcode_13_index_dir="${BUILT_PRODUCTS_DIR/\/Build\/Products\///Index/Build/Products/}"

# Xcode 14 renamed 'Index' to 'Index.noindex'
readonly xcode_14_index_dir="${BUILT_PRODUCTS_DIR/\/Build\/Products\///Index.noindex/Build/Products/}"

readonly dirs=(
  "$xcode_12_index_dir"
  "$xcode_13_index_dir"
  "$xcode_14_index_dir"
)

for index_dir in "${dirs[@]}"; do
    for module in "$@"; do
        doc="${module%.swiftmodule}.swiftdoc"
        sourceinfo="${module%.swiftmodule}.swiftsourceinfo"
        module_name=$(basename "$module")
        module_bundle="$index_dir/$module_name"
        sourceinfo_dir="$module_bundle/Project"
        mkdir -p "$sourceinfo_dir"

        cp "$module" "$module_bundle/${ARCHS[0]}.swiftmodule" || true
        cp "$doc" "$module_bundle/${ARCHS[0]}.swiftdoc" || true
        cp "$sourceinfo" "$sourceinfo_dir/${ARCHS[0]}.swiftsourceinfo" || true

        ios_module_name="${ARCHS[0]}-$LLVM_TARGET_TRIPLE_VENDOR-$SWIFT_PLATFORM_TARGET_PREFIX$LLVM_TARGET_TRIPLE_SUFFIX"
        cp "$module" "$module_bundle/$ios_module_name.swiftmodule" || true
        cp "$doc" "$module_bundle/$ios_module_name.swiftdoc" || true
        cp "$sourceinfo" "$sourceinfo_dir/$ios_module_name.swiftsourceinfo" || true

        chmod -R +w "$module_bundle"
    done
done
