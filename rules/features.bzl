"""
Defines features specific to rules_ios

- `apple.virtualize_frameworks`
  - Virtualize means that swift,clang read from llvm's in-memory file system

- `xcode.compile_with_xcode`
  - Some of the rules need to work sligntly differently under pure Xcode mode

- `apple.arm64_simulator_use_device_deps`
  - Use the ARM deps for the simulator - see rules/import_middleman.bzl

- `swift.swift_disable_import_underlying_module`
  - When set disable passing the `-import-underlying-module` copt to `swift_library` targets
"""

feature_names = struct(
    # Virtualize means that swift,clang read from llvm's in-memory file system
    virtualize_frameworks = "apple.virtualize_frameworks",

    # Some of the rules need to work sligntly differently under pure Xcode mode
    compile_with_xcode = "xcode.compile_with_xcode",

    # Use the ARM deps for the simulator - see rules/import_middleman.bzl
    arm64_simulator_use_device_deps = "apple.arm64_simulator_use_device_deps",

    # When set disable passing the `-import-underlying-module` copt to `swift_library` targets
    swift_disable_import_underlying_module = "swift.swift_disable_import_underlying_module",
)
