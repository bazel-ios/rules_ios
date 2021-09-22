#!/bin/bash

set -euo pipefail

# Xcode 12 and under stored index information in /DerivedData/<project>/Build/Products
readonly xcode_12_index_dir="$BUILT_PRODUCTS_DIR"

# Xcode 13 and later store index information in /DerivedData/<project>/Index/Build/Products
readonly xcode_13_index_dir="${BUILT_PRODUCTS_DIR/\/Build\/Products\///Index/Build/Products/}"

readonly dirs=(
  "$xcode_12_index_dir"
  "$xcode_13_index_dir"
)

for index_dir in "${dirs[@]}"; do
    for module in "$@"; do
        doc="${module%.swiftmodule}.swiftdoc"
        module_name=$(basename "$module")
        module_bundle="$index_dir/$module_name"
        mkdir -p "$module_bundle"

        cp "$module" "$module_bundle/$CURRENT_ARCH.swiftmodule" || true
        cp "$doc" "$module_bundle/$CURRENT_ARCH.swiftdoc" || true

        ios_module_name="$CURRENT_ARCH-$LLVM_TARGET_TRIPLE_VENDOR-$SWIFT_PLATFORM_TARGET_PREFIX$LLVM_TARGET_TRIPLE_SUFFIX"
        cp "$module" "$module_bundle/$ios_module_name.swiftmodule" || true
        cp "$doc" "$module_bundle/$ios_module_name.swiftdoc" || true

        chmod -R +w "$module_bundle"
    done
done
