#!/bin/bash

set -euo pipefail

for module in "$@"; do
    doc="${module%.swiftmodule}.swiftdoc"
    module_name=$(basename "$module")
    module_bundle="$BUILT_PRODUCTS_DIR/$module_name"
    mkdir -p "$module_bundle"

    cp "$module" "$module_bundle/$CURRENT_ARCH.swiftmodule"
    cp "$doc" "$module_bundle/$CURRENT_ARCH.swiftdoc"

    ios_module_name="$CURRENT_ARCH-$LLVM_TARGET_TRIPLE_VENDOR-$SWIFT_PLATFORM_TARGET_PREFIX$LLVM_TARGET_TRIPLE_SUFFIX"
    cp "$module" "$module_bundle/$ios_module_name.swiftmodule"
    cp "$doc" "$module_bundle/$ios_module_name.swiftdoc"

    chmod -R +w "$module_bundle"
done
