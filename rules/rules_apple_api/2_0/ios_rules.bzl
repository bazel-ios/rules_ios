load("@build_bazel_rules_apple//apple/internal:rule_factory.bzl", "rule_factory")

#load("@build_bazel_rules_apple//apple/internal:providers.bzl", "new_appleresourcebundleinfo", "new_appleresourceinfo")
def _common_tool_attrs():
    return rule_factory.common_tool_attributes

rule_attrs = struct(common_tool_attrs = _common_tool_attrs)
