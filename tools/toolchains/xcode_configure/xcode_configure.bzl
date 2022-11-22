# Copyright 2016 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Repository rule to generate host xcode_config and xcode_version targets.

   The xcode_config and xcode_version targets are configured for xcodes/SDKs
   installed on the local host.
"""

load(":xcode_locator.bzl", "run_xcode_locator", "search_string", "xcode_version_output")
load(":xcode_sdk_frameworks.bzl", "xcode_sdk_frameworks")

_EXECUTE_TIMEOUT = 120

def _darwin_build_file(repository_ctx):
    """Evaluates local system state to create xcode_config and xcode_version targets."""
    env = repository_ctx.os.environ
    xcodebuild_result = repository_ctx.execute([
        "env",
        "-i",
        "DEVELOPER_DIR={}".format(env.get("DEVELOPER_DIR", default = "")),
        "xcrun",
        "xcodebuild",
        "-version",
    ], _EXECUTE_TIMEOUT)

    toolchains = run_xcode_locator(
        repository_ctx,
        Label(repository_ctx.attr.xcode_locator),
    )

    default_xcode_version = ""
    default_xcode_build_version = ""
    if xcodebuild_result.return_code == 0:
        default_xcode_version = search_string(xcodebuild_result.stdout, "Xcode ", "\n")
        default_xcode_build_version = search_string(
            xcodebuild_result.stdout,
            "Build version ",
            "\n",
        )
    default_xcode_target = ""
    target_names = []
    buildcontents = ""

    for toolchain in toolchains:
        version = toolchain.version
        aliases = toolchain.aliases
        developer_dir = toolchain.developer_dir
        target_name = "version%s" % version.replace(".", "_")
        version_output = xcode_version_output(
            repository_ctx,
            target_name,
            version,
            aliases,
            developer_dir,
        )
        buildcontents += version_output
        target_label = "':%s'" % target_name
        target_names.append(target_label)
        if (version.startswith(default_xcode_version) and
            version.endswith(default_xcode_build_version)):
            default_xcode_target = target_label
    buildcontents += "xcode_config(name = 'host_xcodes',"
    if target_names:
        buildcontents += "\n  versions = [%s]," % ", ".join(target_names)
    if not default_xcode_target and target_names:
        default_xcode_target = sorted(target_names, reverse = True)[0]
        print("No default Xcode version is set with 'xcode-select'; picking %s" %
              default_xcode_target)
    if default_xcode_target:
        buildcontents += "\n  default = %s," % default_xcode_target

    buildcontents += "\n)\n"
    buildcontents += "available_xcodes(name = 'host_available_xcodes',"
    if target_names:
        buildcontents += "\n  versions = [%s]," % ", ".join(target_names)
    if default_xcode_target:
        buildcontents += "\n  default = %s," % default_xcode_target
    buildcontents += "\n)\n"
    if repository_ctx.attr.remote_xcode:
        buildcontents += "xcode_config(name = 'all_xcodes',"
        buildcontents += "\n  remote_versions = '%s', " % repository_ctx.attr.remote_xcode
        buildcontents += "\n  local_versions = ':host_available_xcodes', "
        buildcontents += "\n)\n"
    return buildcontents

VERSION_CONFIG_STUB = "xcode_config(name = 'host_xcodes')"

def _impl(repository_ctx):
    """Implementation for the local_config_xcode repository rule.

    Generates a BUILD file containing a root xcode_config target named 'host_xcodes',
    which points to an xcode_version target for each version of xcode installed on
    the local host machine. If no versions of xcode are present on the machine
    (for instance, if this is a non-darwin OS), creates a stub target.

    Args:
      repository_ctx: The repository context.
    """

    os_name = repository_ctx.os.name.lower()
    build_contents = "package(default_visibility = ['//visibility:public'])\n\n"
    if (os_name.startswith("mac os")):
        build_contents += _darwin_build_file(repository_ctx)
    else:
        build_contents += VERSION_CONFIG_STUB
    repository_ctx.file("BUILD", build_contents)

xcode_autoconf = repository_rule(
    implementation = _impl,
    local = True,
    attrs = {
        "xcode_locator": attr.string(),
        "remote_xcode": attr.string(),
    },
)

def xcode_configure(xcode_locator_label, remote_xcode_label = None):
    """Generates a repository containing host xcode version information."""
    xcode_autoconf(
        name = "local_config_xcode",
        xcode_locator = xcode_locator_label,
        remote_xcode = remote_xcode_label,
    )
    xcode_sdk_frameworks(
        name = "xcode_sdk_frameworks",
        xcode_locator = xcode_locator_label,
    )
