# iOS Rules for [Bazel](https://bazel.build)

![](https://github.com/ob/rules_ios/workflows/master/badge.svg)

> :warning: **This is alpha software.** We are developing these rules in the open so you should only use them if you know what you are doing and are willing to help develop them.



These rules provide some macros and rules that make it easier to build iOS
application with Bazel. The heavy lifting of compiling, and packaging is
still done by the existing
 [`objc_library` rule](https://bazel.build/versions/master/docs/be/objective-c.html#objc_library)
in Bazel, and by the
[`swift_library` rule](https://github.com/bazelbuild/rules_swift/blob/master/doc/rules.md#swift_library)
available from [rules_swift](https://github.com/bazelbuild/rules_swift).

These rules require Bazel 2.0.

## Reference documentation

[Click here](https://github.com/ob/rules_ios/tree/master/doc)
for the documentation.

## Quick setup

Add the following lines to your `WORKSPACE` file. Note that since `rules_swift`
and `rules_apple` [no longer create
releases](https://github.com/bazelbuild/rules_swift/pull/335), the versions are
hardcoded to commit sha's that are known to work. You can see the particular
commit sha's in
[`repositories.bzl`](https://github.com/ob/rules_ios/tree/master/rules/repositories.bzl).

```python
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "build_bazel_rules_ios",
    remote = "https://github.com/ob/rules_ios.git",
    branch = "master",
)

load(
    "@build_bazel_rules_ios//rules:app.bzl",
    "ios_application"
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
```

## Examples

Minimal example:

```python
load("@build_bazel_rules_ios//rules:app.bzl", "ios_application")
load("//rules:framework.bzl", "apple_framework")
  
apple_framework(
    name = "ModuleA",
    srcs = glob([
        "ModuleA/**/*.swift",
        "ModuleA/**/*.m",
        "ModuleA/**/*.h",
    ]),
    visibility = ["//visibility:public"],
    deps = [":ModuleC"]
)

apple_framework(
    name = "ModuleC",
    srcs = glob([
        "ModuleC/**/*.m",
        "ModuleC/**/*.h",
    ]),
    visibility = ["//visibility:public"]
)

apple_framework(
    name = "ModuleD",
    srcs = glob([
        "ModuleD/**/*.swift",
    ]),
    visibility = ["//visibility:public"],
    deps = [":ModuleE"]
)

apple_framework(
    name = "ModuleE",
    srcs = glob([
        "ModuleE/**/*.swift",
    ]),
    visibility = ["//visibility:public"]
)

############### MixedTest #################################
ios_application(
    name = "Mixedtest",
    srcs = glob([
        "TestApp/**/*.swift",
    ]),
    bundle_id = "com.example.mixed-app",
    families = [
        "iphone",
    ],

    deps = [":ModuleA"],
    minimum_os_version = "12.0",
)
```

See the [examples](https://github.com/ob/rules_ios/tree/master/examples)
directory for sample applications.
