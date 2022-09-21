# iOS Rules for [Bazel](https://bazel.build)

![master](https://github.com/bazel-ios/rules_ios/workflows/CI-master/badge.svg)

`rules_ios` is community developed Bazel rules to do iOS development with Bazel
end to end.

It seamlessly bazel builds iOS applications originally written under Xcode with
minimal-to-no code changes. It often re-uses ideas and code from `rules_swift`
and `rules_apple` and it isn't tied to untested or unused features. It
generates Xcode projects that _just work_ and makes using Apple Silicion with Bazel a breeze.

### iOS Applications

_it supports all the primitives like apps, extensions, and widgets_

```python
load("@build_bazel_rules_ios//rules:app.bzl", "ios_application")

ios_application(
    name = "iOS-App",
    srcs = glob(["*.m", "*.swift"]),
    bundle_id = "com.example.ios-app",
    minimum_os_version = "12.0",
    visibility = ["//visibility:public"],
)
```

### Xcode project generation

_xcode project generaation that's tested and works end to end with open source
remote execution and caching._

```python
load("@build_bazel_rules_ios//rules:xcodeproj.bzl", "xcodeproj")

xcodeproj(
    name = "MyXcode",
    srcs = glob(["*.m", "*.swift"]),
    bazel_path = "bazelisk",
    deps = [ ":iOS-App"] 
)
```

### Frameworks

_static frameworks with Xcode semantics - easily port existing apps to Bazel_

```python
# Builds a static framework
apple_framework(
    name = "Static",
    srcs = glob(["static/*.swift"]),
    bundle_id = "com.example.b",
    data = ["Static.txt"],
    infoplists = ["Info.plist"],
    link_dynamic = True,
    platforms = {"ios": "10.0"},
    deps = ["//tests/ios/frameworks/dynamic/c"],
)
```

### Dynamic iOS frameworks

_rules_ios builds frameworks as static or dynamic - just flip
`link_dynamic`_

```python
apple_framework(
    name = "Dynamic",
    srcs = glob(["dynamic/*.swift"]),
    bundle_id = "com.example.a",
    infoplists = ["Info.plist"],
    link_dynamic = True,
    platforms = {"ios": "10.0"},
    deps = [":Static"],
)
```

### Testing - UI / Unit

_easily test iOS applications with Bazel - ui and unit testing rules_

```python
load("//rules:test.bzl", "ios_unit_test")

ios_unit_test(
    name = "Unhosted",
    srcs = ["some.swift"],
    minimum_os_version = "11.0",
    deps = [":Dynamic"]
)
```

### Apple Silicon ready

- Automatically run legacy deps on Apple Silicon - it _just works_ by running [arm64-to-sim](https://github.com/bogo/arm64-to-sim) and more.
- Testing mechanisms to easily test in ephemeral VMs

## WORKSPACE setup

Add the following lines to your `WORKSPACE` file. Note that since `rules_swift`
and `rules_apple` [no longer create
releases](https://github.com/bazelbuild/rules_swift/pull/335), the versions are
hardcoded to commit sha's that are known to work. You can see the particular
commit sha's in
[`repositories.bzl`](https://github.com/bazel-ios/rules_ios/tree/master/rules/repositories.bzl).

```python
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "build_bazel_rules_ios",
    remote = "https://github.com/bazel-ios/rules_ios.git",
    branch = "master",
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

_See the [tests](https://github.com/bazel-ios/rules_ios/tree/master/tests)
directory for tested use cases.

## Special notes about debugging xcode projects
Debugging does not work in sandbox mode, due to issue [#108](https://github.com/bazel-ios/rules_ios/issues/108). The workaround for now is to disable sandboxing in the .bazelrc file.

## 


Bazel version required by current rules is [here](https://github.com/bazel-ios/rules_ios/blob/master/.bazelversion)

**Xcode 12** and above supported, to find the last `SHA` with support for older versions see the list of git tags.

## Reference documentation

[Click here](https://github.com/bazel-ios/rules_ios/tree/master/docs)
for the documentation.


