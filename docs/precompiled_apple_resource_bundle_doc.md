<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a id="#precompiled_apple_resource_bundle"></a>

## precompiled_apple_resource_bundle

<pre>
precompiled_apple_resource_bundle(<a href="#precompiled_apple_resource_bundle-name">name</a>, <a href="#precompiled_apple_resource_bundle-bundle_extension">bundle_extension</a>, <a href="#precompiled_apple_resource_bundle-bundle_id">bundle_id</a>, <a href="#precompiled_apple_resource_bundle-bundle_name">bundle_name</a>, <a href="#precompiled_apple_resource_bundle-infoplists">infoplists</a>,
                                  <a href="#precompiled_apple_resource_bundle-ipa_post_processor">ipa_post_processor</a>, <a href="#precompiled_apple_resource_bundle-platforms">platforms</a>, <a href="#precompiled_apple_resource_bundle-resources">resources</a>, <a href="#precompiled_apple_resource_bundle-swift_module">swift_module</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="precompiled_apple_resource_bundle-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="precompiled_apple_resource_bundle-bundle_extension"></a>bundle_extension |  The extension of the resource bundle.   | String | optional | "bundle" |
| <a id="precompiled_apple_resource_bundle-bundle_id"></a>bundle_id |  The bundle identifier of the resource bundle.   | String | optional | "" |
| <a id="precompiled_apple_resource_bundle-bundle_name"></a>bundle_name |  The name of the resource bundle. Defaults to the target name.   | String | optional | "" |
| <a id="precompiled_apple_resource_bundle-infoplists"></a>infoplists |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [Label("@build_bazel_rules_ios//rules/library:resource_bundle.plist")] |
| <a id="precompiled_apple_resource_bundle-ipa_post_processor"></a>ipa_post_processor |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="precompiled_apple_resource_bundle-platforms"></a>platforms |  A dictionary of platform names to minimum deployment targets. If not given, the resource bundle will be built for the platform it inherits from the target that uses the bundle as a dependency.   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a> | optional | {} |
| <a id="precompiled_apple_resource_bundle-resources"></a>resources |  The list of resources to be included in the resource bundle.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="precompiled_apple_resource_bundle-swift_module"></a>swift_module |  The swift module to use when compiling storyboards, nibs and xibs that contain a customModuleProvider   | String | optional | "" |


