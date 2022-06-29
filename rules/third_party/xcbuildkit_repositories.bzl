"""
Copied from: https://github.com/jerrymarino/xcbuildkit/blob/master/third_party/repositories.bzl
"""

load(
    "@bazel_tools//tools/build_defs/repo:git.bzl",
    "git_repository",
    "new_git_repository",
)
load("//rules/third_party:xcbuildkit_version.bzl", "repo_info")

NAMESPACE_PREFIX = "xcbuildkit-"

def namespaced_name(name):
    if name.startswith("@"):
        return name.replace("@", "@%s" % NAMESPACE_PREFIX)
    return NAMESPACE_PREFIX + name

def namespaced_dep_name(name):
    if name.startswith("@"):
        return name.replace("@", "@%s" % NAMESPACE_PREFIX)
    return name

def namespaced_new_git_repository(name, **kwargs):
    new_git_repository(
        name = namespaced_name(name),
        **kwargs
    )

def namespaced_git_repository(name, **kwargs):
    git_repository(
        name = namespaced_name(name),
        **kwargs
    )

def namespaced_build_file(libs):
    return """
package(default_visibility = ["//visibility:public"])
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_c_module",
"swift_library")
""" + "\n\n".join(libs)

def namespaced_swift_c_library(name, srcs, hdrs, includes, module_map):
    return """
objc_library(
  name = "{name}Lib",
  srcs = glob([
    {srcs}
  ]),
  hdrs = glob([
    {hdrs}
  ]),
  includes = [
    {includes}
  ]
)

swift_c_module(
  name = "{name}",
  deps = [":{name}Lib"],
  module_map = "{module_map}",
)
""".format(**dict(
        name = name,
        srcs = ",\n".join(['"%s"' % x for x in srcs]),
        hdrs = ",\n".join(['"%s"' % x for x in hdrs]),
        includes = ",\n".join(['"%s"' % x for x in includes]),
        module_map = module_map,
    ))

def namespaced_swift_library(name, srcs, deps = None, defines = None, copts = []):
    deps = [] if deps == None else deps
    defines = [] if defines == None else defines
    return """
swift_library(
    name = "{name}",
    srcs = glob([{srcs}]),
    module_name = "{name}",
    deps = [{deps}],
    defines = [{defines}],
    copts = ["-DSWIFT_PACKAGE", {copts}],
)""".format(**dict(
        name = name,
        srcs = ",\n".join(['"%s"' % x for x in srcs]),
        defines = ",\n".join(['"%s"' % x for x in defines]),
        deps = ",\n".join(['"%s"' % namespaced_dep_name(x) for x in deps]),
        copts = ",\n".join(['"%s"' % x for x in copts]),
    ))

def dependencies():
    """Fetches repositories that are dependencies of the workspace.

    Users should call this macro in their `WORKSPACE` to ensure that all of the
    dependencies of  are downloaded and that they are isolated from
    changes to those dependencies.
    """
    namespaced_new_git_repository(
        name = "SwiftProtobuf",
        remote = "https://github.com/apple/swift-protobuf.git",
        build_file_content = namespaced_build_file([
            namespaced_swift_library(
                name = "SwiftProtobuf",
                srcs = ["Sources/SwiftProtobuf/*.swift"],
            ),
        ]),
        commit = "0a8f81884973d7b265dc8cca6b2db2f349aca54d",
    )
    repo_info("xcbuildkit")

    # Fork this internally
    #namespaced_new_git_repository(
    #    name = "MessagePack",
    #    remote = "https://github.com/a2/MessagePack.swift.git",
    #    build_file_content = namespaced_build_file([
    #        namespaced_swift_library(
    #            name = "MessagePack",
    #            srcs = ["Sources/**/*.swift"],
    #        ),
    #    ]),
    #    commit = "69ccf98d50fc253f1d31d033b4fc67b47e5e6230",
    #)
