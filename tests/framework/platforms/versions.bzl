load("//rules:framework.bzl", "apple_framework")
load("//rules:app.bzl", "ios_application")

_VERSIONS = {
    "macos": ["10.13", "15.2"],
    "ios": ["12.0", "16.2", "17.2"],
    "tvos": ["12.0", "16.2", "17.2"],
    "watchos": ["3.2"],
}

def _version_int(version):
    parts = [int(x) for x in version.split(".")]
    if len(parts) not in (2, 3):
        fail("must have two/three parts")

    major = parts[0]
    minor = parts[1]
    patch = 0 if len(parts) == 2 else parts[2]

    return patch + minor * 100 + major * 10000

_MULTIPLATFORM = {
    k: v[0]
    for (k, v) in _VERSIONS.items()
}
_MULTIPLATFORM_SUFFIX = "".join(["_{}_{}".format(platform, _version_int(version)) for (platform, version) in _MULTIPLATFORM.items()])

def _make_framework(prefix, srcs, deps, platforms, resources_to_bundle):
    name = prefix
    defines = {}
    for (platform, version) in platforms.items():
        version_int = _version_int(version)
        defines["TEST_PLATFORM_%s" % platform] = "1"
        defines["TEST_VERSION_%s" % platform] = "1"
        defines["TEST_VERSION_%s" % platform] = version_int
        defines["TEST_VERSION_%s_%s" % (platform, version_int)] = "1"
        name += "_{}_{}".format(platform, version_int)
    defines["BAZEL_TARGET_NAME"] = name

    apple_framework(
        name = name,
        srcs = srcs,
        objc_copts = [
            "-D{}={}".format(k, v)
            for (k, v) in defines.items()
        ],
        platforms = platforms,
        deps = deps,
        resource_bundles = {"{}_resources".format(name): resources_to_bundle},
    )

def make_frameworks(srcs, prefix = "framework", deps = [], resources_to_bundle = []):
    for platform, versions in _VERSIONS.items():
        for version in versions:
            _make_framework(
                prefix = prefix,
                srcs = srcs,
                deps = deps,
                resources_to_bundle = resources_to_bundle,
                platforms = {platform: version},
            )

    _make_framework(
        prefix = prefix,
        srcs = srcs,
        deps = deps,
        resources_to_bundle = resources_to_bundle,
        platforms = _MULTIPLATFORM,
    )

def make_frameworks_with_dependencies(srcs, resources_to_bundle):
    make_frameworks(prefix = "framework_deps", srcs = srcs, resources_to_bundle = resources_to_bundle, deps = [":framework" + _MULTIPLATFORM_SUFFIX])

def make_applications(srcs):
    existing_rules = native.existing_rules()

    for (platform, versions) in _VERSIONS.items():
        if platform != "ios":
            continue

        for version in versions:
            version_int = _version_int(version)
            ios_application(
                name = "ios_application_{}".format(version_int),
                srcs = srcs,
                minimum_os_version = version,
                deps = [d for (d, t) in existing_rules.items() if "_ios_" in d and t["kind"] == "apple_framework_packaging"],
                entitlements = None,
                bundle_id = "com.example.iosapplication",
            )
