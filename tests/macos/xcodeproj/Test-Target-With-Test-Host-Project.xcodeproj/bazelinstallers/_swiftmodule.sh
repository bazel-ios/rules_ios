#!/bin/bash

set -euo pipefail

for module in "$@"; do
    doc="${module%.swiftmodule}.swiftdoc"
    module_name=$(basename "$module")
    module_bundle="$BUILT_PRODUCTS_DIR/$module_name"
    mkdir -p "$module_bundle"

    cp "$module" "$module_bundle/$NATIVE_ARCH_ACTUAL.swiftmodule"
    cp "$doc" "$module_bundle/$NATIVE_ARCH_ACTUAL.swiftdoc"

    ios_module_name="$NATIVE_ARCH_ACTUAL-$LLVM_TARGET_TRIPLE_VENDOR-$SWIFT_PLATFORM_TARGET_PREFIX$LLVM_TARGET_TRIPLE_SUFFIX"
    cp "$module" "$module_bundle/$ios_module_name.swiftmodule"
    cp "$doc" "$module_bundle/$ios_module_name.swiftdoc"

    chmod -R +w "$module_bundle"
done
