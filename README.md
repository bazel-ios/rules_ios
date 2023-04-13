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

### iOS Applications

_it supports all the primitives like apps, extensions, and widgets_

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

There are currently at least three options to generate Xcode projects that build with Bazel.

`rules_ios` has its own project generator that is considered stable and ready to be used in production. Here's a minimal example of how to load it in your `BUILD` file:
```python
load("@build_bazel_rules_ios//rules:xcodeproj.bzl", "xcodeproj")

xcodeproj(
    name = "MyXcode",
    bazel_path = "bazelisk",
    deps = [ ":iOS-App"] 
)
```
Checkout [legacy_xcodeproj.bzl](https://github.com/bazel-ios/rules_ios/blob/master/rules/legacy_xcodeproj.bzl) for available attributes.

Alternatively the `bazel-ios` org has forks of both [XCHammer](https://github.com/bazel-ios/xchammer) and [Tulsi](https://github.com/bazel-ios/tulsi) with some changes to make it work with `rules_ios` and optionally enable the "build with Xcode" use case. This is currently considered "alpha" software and not recommended to be used in production. If you want to test it out when loading `rules_ios` per [WORKSPACE setup](#workspace-setup) instructions below load `rules_ios` dependencies like so
```python
rules_ios_dependencies(load_xchammer_dependencies = True)
```
and additionally pass this attribute to the `xcodeproj` macro above `use_xchammer = True`, optionally pass `generate_xcode_schemes = True` to build with Xcode.

Last, [rules_xcodeproj](https://github.com/MobileNativeFoundation/rules_xcodeproj) is another great alternative and we're working with them to better integrate it with `rules_ios`. Checkout [examples/rules_ios](https://github.com/MobileNativeFoundation/rules_xcodeproj/tree/main/examples/rules_ios) for examples of how to use it with `rules_ios`.

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
    platforms = {"ios": "12.0"},
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
    platforms = {"ios": "12.0"},
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

Add the following lines to your `WORKSPACE` file.

_It pulls a vetted sha of `rules_apple` and `rules_swift` - you can find the
versions in
[`repositories.bzl`](https://github.com/bazel-ios/rules_ios/tree/master/rules/repositories.bzl)._

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

**Xcode 13** and above supported, to find the last `SHA` with support for older versions see the list of git tags.

## Reference documentation

[Click here](https://github.com/bazel-ios/rules_ios/tree/master/docs)
for the documentation.


## 5.x.x LTS Support on HEAD

LTS is a concept in [Bazel for versions](https://blog.bazel.build/2020/11/10/long-term-support-release.html)
and we currently support 5.x.x only for a brief time. _The rough ETA for
removing Bazel 5.x.x LTS support is end of Q2 2023 and if it's an issue we can
correct course sooner._

Because `rules_ios` should be loosely coupled to a given Bazel version, we can
often handle several Bazel versions concurrently on `HEAD` without significant
change and without having to have CI and review for LTS branches. Because we
want to keep running on `HEAD`, LTS support is added with branches where
necessary.  _The idea is paralleled to other to large scale migrations or python
code which supported 2.x.x and 3.x.x concurrently_.

We have a Bazel 5.x.x CI job which is the source of truth for vetting this.

### rules_apple: What's up with rules_ios_1.0

For `rules_apple` we attempt to achieve multi versions and smoothing over
maintainer velocity issues on a patched tag. For instance we may back-ported
some features to our tag like [framework_import_support](https://github.com/bazel-ios/rules_apple/commit/78476e542160be2c32d467ef856ccc2e9152f187)

### Maintainer concerns and rules_apple compatability

We may shim APIs, back port patches from `rules_apple` to add features and
smooth over integration. The unstable tag `rules_ios_1.0` has it all. If you're
just bumping `rules_apple` for Bazel 6.0 you shouldn't need to worry about the
LTS support if it passes CI. The burden to be an outlier should fall on the
outliers here - if you've got an issue we can look into it together.


