feature_names = struct(
    # Virtualize means that swift,clang read from llvm's in-memory file system
    virtualize_frameworks = "apple.virtualize_frameworks",

    # Use the ARM deps for the simulator - see rules/import_middleman.bzl
    arm64_simulator_use_device_deps = "apple.arm64_simulator_use_device_deps",
)
