# iOS Rules for [Bazel](https://bazel.build)

![master](https://github.com/bazel-ios/rules_ios/workflows/CI-master/badge.svg)

> :warning: **This is alpha software.** We are developing these rules in the open so you should only use them if you know what you are doing and are willing to help develop them.



These rules provide some macros and rules that make it easier to build iOS
application with Bazel. The heavy lifting of compiling, and packaging is
still done by the existing
 [`objc_library` rule](https://bazel.build/versions/master/docs/be/objective-c.html#objc_library)
in Bazel, and by the
[`swift_library` rule](https://github.com/bazelbuild/rules_swift/blob/master/doc/rules.md#swift_library)
available from [rules_swift](https://github.com/bazelbuild/rules_swift).

Bazel version required by current rules is [here](https://github.com/bazel-ios/rules_ios/blob/master/.bazelversion)

## Reference documentation

[Click here](https://github.com/bazel-ios/rules_ios/tree/master/docs)
for the documentation.

## Quick setup

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
```

## Examples

Minimal example:

```python
load("@build_bazel_rules_ios//rules:app.bzl", "ios_application")

ios_application(
    name = "iOS-App",
    srcs = glob(["*.m"]),
    bundle_id = "com.example.ios-app",
    entitlements = "ios.entitlements",
    families = [
        "iphone",
        "ipad",
    ],
    launch_storyboard = "LaunchScreen.storyboard",
    minimum_os_version = "12.0",
    visibility = ["//visibility:public"],
)
```

See the [tests](https://github.com/bazel-ios/rules_ios/tree/master/tests)
directory for sample applications.

## Special notes about debugging xcode projects
Note that when generating Xcode projects, it is necessary to supply the `--@build_bazel_rules_ios//rules:local_debug_options_enabled` so that debugging of swift files will work.

Debugging does not work in sandbox mode, due to issue #108. The workaround for now is to disable sandboxing in the .bazelrc file.
