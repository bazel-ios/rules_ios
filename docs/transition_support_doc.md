<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Starlark transition support for Apple rules.

This module makes the following distinctions around Apple CPU-adjacent values for clarity, based in
part on the language used for XCFramework library identifiers:

- `architecture`s or "arch"s represent the type of binary slice ("arm64", "x86_64").

- `environment`s represent a platform variant ("device", "sim"). These sometimes appear in the "cpu"
    keys out of necessity to distinguish new "cpu"s from an existing Apple "cpu" when a new
    Crosstool-provided toolchain is established.

- `platform_type`s represent the Apple OS being built for ("ios", "macos", "tvos", "visionos",
    "watchos").

- `cpu`s are keys to match a Crosstool-provided toolchain ("ios_sim_arm64", "ios_x86_64").
    Essentially it is a raw key that implicitly references the other three values for the purpose of
    getting the right Apple toolchain to build outputs with from the Apple Crosstool.

<a id="transition_support.current_apple_platform"></a>

## transition_support.current_apple_platform

<pre>
load("@rules_ios//rules:transition_support.bzl", "transition_support")

transition_support.current_apple_platform(<a href="#transition_support.current_apple_platform-apple_fragment">apple_fragment</a>, <a href="#transition_support.current_apple_platform-xcode_config">xcode_config</a>)
</pre>

Returns a struct containing the platform and target os version

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="transition_support.current_apple_platform-apple_fragment"></a>apple_fragment |  <p align="center"> - </p>   |  none |
| <a id="transition_support.current_apple_platform-xcode_config"></a>xcode_config |  <p align="center"> - </p>   |  none |


