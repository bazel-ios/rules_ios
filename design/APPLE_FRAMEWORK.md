# Apple Framework

Based on previous experience compiling large iOS applications, this document
describes the type of rule that would make it easy for iOS developers to create
Bazel build rules.

The key insight is that unlike `rules_apple` and `objc_library()` where you have
build rules and packaging rules, this `apple_framework()` rule can be used as a dependency.

```python
# Framework Foobar
apple_framework(
    name = "Foobar",
    module_name = "Foobar",  # optional, default to name
    module_map = "",  # optional... objc only
                      # we'll add the swift stuff under the hood

    # private sources
    srcs = glob([
        "*.swift",
        "*.m",
        "*.mm",
        "*.hh",
        "*.h",
    ]),
    non_arc_srcs = glob(),  # same as objc_library rule
    # public headers
    hdrs = glob([
        "*.h",
        "*.hh",
    ]),
    pch = "",  # same as objc
    # same as rules_swift
    data = glob([]),
    resource_bundles = {
        "name_of_the_bundle": glob([
            "**/stuff_that_goes_into_bundle...",
            "*.png",
        ]),
        "more_bundle": glob([]),
    },
    # non-propagated stuff
    swift_copts = ["-stuff"],
    objc_copts = ["--stuff"],
    cc_copts = ["--stuff"],

    # propagated
    defines = ["foo=bar"],
    linkopts = ["--stuff"],
    other_inputs = [],  # stuff that you need, like swiftc_inputs
    linking_style = None,  # dynamic vs static, defaults to None, which does
    # The Right Thing(tm)
    runtime_deps = [],
    sdk_dylibs = [],
    sdk_frameworks = [],
    sdk_includes = [],
    weak_sdk_frameworks = [],

    # any compatible provider: CCProvider, SwiftInfo, etc
    deps = [],
)
```

## Terminal Rules

These are rules that don't re-export providers, however, they are _not_
packaging rules, they can also have attributes like `srcs`, `hdrs`, etc.

```python
ios_application()
ios_extension()
ios_unit_test()
ios_ui_test()
```
