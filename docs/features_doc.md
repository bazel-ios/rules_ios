<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Defines features specific to rules_ios

- `apple.virtualize_frameworks`
  - Virtualize means that swift,clang read from llvm's in-memory file system

- `xcode.compile_with_xcode`
  - Some of the rules need to work sligntly differently under pure Xcode mode

- `apple.arm64_simulator_use_device_deps`
  - Use the ARM deps for the simulator - see rules/import_middleman.bzl

- `swift.swift_disable_import_underlying_module`
  - When set disable passing the `-import-underlying-module` copt to `swift_library` targets

