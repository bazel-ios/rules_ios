# iOS Rules for [Bazel](https://bazel.build)

![master](https://github.com/bazel-ios/rules_ios/workflows/CI-master/badge.svg)

`rules_ios` is [community developed Bazel rules](https://bazel-ios.github.io/)
that enable you to do iOS development with Bazel end to end.

It seamlessly Bazel builds iOS applications originally written under Xcode with
minimal-to-no code changes. It often re-uses ideas and code from `rules_swift`
and `rules_apple` and it isn't tied to untested or unused features. It generates
Xcode projects that _just work_ and makes using Apple Silicon with Bazel a
breeze.

_Learn more at [bazel-ios.github.io](https://bazel-ios.github.io/)_

_Looking for the CocoaPods/Carthage rules?_ [See this section](#cocoapods-and-carthage).

## Reference documentation

[Click here](https://github.com/bazel-ios/rules_ios/tree/master/docs)
for the documentation.

## Supported Bazel versions

rules_ios depends on [rules_apple](https://github.com/bazelbuild/rules_apple) and [rules_swift](https://github.com/bazelbuild/rules_swift) which are often affected by changes in Bazel
itself. This means you generally need to update these rules and rules_ios as you
update Bazel.

See the following table for supported release versions.

| Bazel release | Minimum supported rules version | Final supported rules version
|:-------------------:|:-------------------------:|:-------------------------:
| 8.* | 5.4.0 | current
| 7.* | 4.4.0 | current
| 6.* | 2.0.0 | 5.3.0
| 5.* | 1.0.0 | 3.2.2
| 4.* | 1.0.0 | 1.0.0

## Supported [rules_apple](https://github.com/bazelbuild/rules_apple) versions

rules_ios depends on [rules_apple](https://github.com/bazelbuild/rules_apple), we attempt to maintain compatibility with
most versions of rules_apple until it becomes too difficult to do so.

See the following table for supported rules_apple release versions.

| rules_apple release | Minimum supported rules version | Final supported rules version
|:-------------------:|:-------------------------:|:-------------------------:
| 3.15.0 | 5.3.0 | current
| 3.* | 3.* | 4.2.1
| 2.* | 2.* | 3.2.2
| 1.* | 1.0.0 | 3.2.2

## Bazel 8 Migration Guide

If you're upgrading from Bazel 7 to Bazel 8, please note the following changes:

### Important Changes
- The `apple_common.AppleDynamicFramework` provider has been removed in Bazel 8
- Several ObjcInfo provider fields have been removed, including:
  - `force_load_library`
  - `imported_library`
  - `library`
  - `static_framework_file`
  - And others related to linking

### Required Updates
1. Update rules_ios to version 5.4.0 or later
2. Update your dependencies in MODULE.bazel:
   - `apple_support` to 1.21.1 or later
   - `rules_cc` to 0.0.16 or later
   - `bazel_skylib` to 1.7.1 or later

### Compatibility
rules_ios 5.4.0+ maintains compatibility with both Bazel 7 and Bazel 8, so you can safely update before migrating to Bazel 8.

## Getting started

### Bzlmod setup

Add the Bazel module to your `MODULE.bazel` file:
See the [latest release](https://github.com/bazel-ios/rules_ios/releases/latest) for an up-to-date snippet!

```bzl
bazel_dep(name = "rules_ios", version = "x.x.x", repo_name = "build_bazel_rules_ios")
```

### WORKSPACE setup

Add the following lines to your `WORKSPACE` file.
See the [latest release](https://github.com/bazel-ios/rules_ios/releases/latest) for an up-to-date snippet!

```bzl
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# See https://github.com/bazel-ios/rules_ios/releases/latest
http_archive(
    name = "build_bazel_rules_ios",
    sha256 = "4faa33a671f615500d3ec0d04d89e390103bcc1abb5e973c8fb1c2510af85985",
    url = "https://github.com/bazel-ios/rules_ios/releases/download/1.0.1/rules_ios.1.0.1.tar.gz",
)

load(
    "@build_bazel_rules_ios//rules:repositories.bzl",
    "rules_ios_dependencies"
)

rules_ios_dependencies()

load(
    "@build_bazel_rules_apple//apple:repositories.bzl",
    "apple_rules_dependencies",
)

apple_rules_dependencies()

load(
    "@build_bazel_rules_swift//swift:repositories.bzl",
    "swift_rules_dependencies",
)

swift_rules_dependencies()

load(
    "@build_bazel_apple_support//lib:repositories.bzl",
    "apple_support_dependencies",
)

apple_support_dependencies()

load(
    "@com_google_protobuf//:protobuf_deps.bzl",
    "protobuf_deps",
)

protobuf_deps()
```

rules_ios pulls a vetted sha of `rules_apple` and `rules_swift` - you can find the versions in [`repositories.bzl`](https://github.com/bazel-ios/rules_ios/tree/master/rules/repositories.bzl).

### iOS applications

rules_ios supports all the primitives like apps, extensions, app clips, and widgets

For example, create an iOS app like so:

```python
load("@build_bazel_rules_ios//rules:app.bzl", "ios_application")

ios_application(
    name = "iOS-App",
    srcs = glob(["*.swift"]),
    bundle_id = "com.example.ios-app",
    minimum_os_version = "12.0",
    visibility = ["//visibility:public"],
)
```

### Xcode project generation

See [rules_xcodeproj](https://github.com/MobileNativeFoundation/rules_xcodeproj).

### Frameworks

Static frameworks with Xcode semantics - easily port existing apps to Bazel

```python
# Builds a static framework
apple_framework(
    name = "Static",
    srcs = glob(["static/*.swift"]),
    bundle_id = "com.example.b",
    data = ["Static.txt"],
    infoplists = ["Info.plist"],
    platforms = {"ios": "12.0"},
    deps = ["//tests/ios/frameworks/dynamic/c"],
)
```

### Dynamic iOS frameworks

rules_ios builds frameworks as static or dynamic - just flip
`link_dynamic`

```python
apple_framework(
    name = "Dynamic",
    srcs = glob(["dynamic/*.swift"]),
    bundle_id = "com.example.a",
    infoplists = ["Info.plist"],
    link_dynamic = True,
    platforms = {"ios": "12.0"},
    deps = [":Static"],
)
```

### Testing - UI / Unit

Easily test iOS applications with Bazel - ui and unit testing rules

```python
load("//rules:test.bzl", "ios_unit_test")

ios_unit_test(
    name = "Unhosted",
    srcs = ["some.swift"],
    minimum_os_version = "12.0",
    deps = [":Dynamic"]
)
```

### Apple Silicon ready

- Automatically run legacy deps on Apple Silicon - it _just works_ by running [arm64-to-sim](https://github.com/bogo/arm64-to-sim) and more.
- Testing mechanisms to easily test in ephemeral VMs

## Examples

See the [tests](https://github.com/bazel-ios/rules_ios/tree/master/tests)
directory for tested use cases.

## Special notes about debugging xcode projects

Debugging does not work in sandbox mode, due to issue [#108](https://github.com/bazel-ios/rules_ios/issues/108). The workaround for now is to disable sandboxing in the .bazelrc file.

Bazel version required by current rules is [here](https://github.com/bazel-ios/rules_ios/blob/master/.bazelversion)

**Xcode 13** and above supported, to find the last `SHA` with support for older versions see the list of git tags.

## CocoaPods and Carthage

The existing CocoaPods and Carthage rules have been removed for maintenance reasons, instead use these other solutions:

- For CocoaPods: [cocoapods-bazel](https://github.com/bazel-ios/cocoapods-bazel)
- For Carthage: [apple_framework_import](https://github.com/bazelbuild/rules_apple/blob/master/doc/rules-apple.md#apple_dynamic_framework_import)

## Contributing

For information on contributing / maintaining this repository see: [CONTRIBUTING.md](./CONTRIBUTING.md)
