<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Framework rules

<a id="apple_framework_packaging"></a>

## apple_framework_packaging

<pre>
apple_framework_packaging(<a href="#apple_framework_packaging-name">name</a>, <a href="#apple_framework_packaging-bundle_extension">bundle_extension</a>, <a href="#apple_framework_packaging-bundle_id">bundle_id</a>, <a href="#apple_framework_packaging-data">data</a>, <a href="#apple_framework_packaging-deps">deps</a>, <a href="#apple_framework_packaging-environment_plist">environment_plist</a>,
                          <a href="#apple_framework_packaging-exported_symbols_lists">exported_symbols_lists</a>, <a href="#apple_framework_packaging-framework_name">framework_name</a>, <a href="#apple_framework_packaging-frameworks">frameworks</a>, <a href="#apple_framework_packaging-infoplists">infoplists</a>,
                          <a href="#apple_framework_packaging-library_linkopts">library_linkopts</a>, <a href="#apple_framework_packaging-link_dynamic">link_dynamic</a>, <a href="#apple_framework_packaging-minimum_deployment_os_version">minimum_deployment_os_version</a>,
                          <a href="#apple_framework_packaging-minimum_os_version">minimum_os_version</a>, <a href="#apple_framework_packaging-platform_type">platform_type</a>, <a href="#apple_framework_packaging-platforms">platforms</a>, <a href="#apple_framework_packaging-private_deps">private_deps</a>, <a href="#apple_framework_packaging-skip_packaging">skip_packaging</a>,
                          <a href="#apple_framework_packaging-stamp">stamp</a>, <a href="#apple_framework_packaging-transitive_deps">transitive_deps</a>, <a href="#apple_framework_packaging-vfs">vfs</a>)
</pre>

Packages compiled code into an Apple .framework package

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="apple_framework_packaging-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="apple_framework_packaging-bundle_extension"></a>bundle_extension |  The extension of the bundle, defaults to "framework".   | String | optional | <code>"framework"</code> |
| <a id="apple_framework_packaging-bundle_id"></a>bundle_id |  The bundle identifier of the framework. Currently unused.   | String | optional | <code>""</code> |
| <a id="apple_framework_packaging-data"></a>data |  Objc or Swift rules to be packed by the framework rule   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="apple_framework_packaging-deps"></a>deps |  Objc or Swift rules to be packed by the framework rule   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="apple_framework_packaging-environment_plist"></a>environment_plist |  An executable file referencing the environment_plist tool. Used to merge infoplists. See https://github.com/bazelbuild/rules_apple/blob/master/apple/internal/environment_plist.bzl#L69   | <a href="https://bazel.build/concepts/labels">Label</a> | optional | <code>None</code> |
| <a id="apple_framework_packaging-exported_symbols_lists"></a>exported_symbols_lists |     | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="apple_framework_packaging-framework_name"></a>framework_name |  Name of the framework, usually the same as the module name   | String | required |  |
| <a id="apple_framework_packaging-frameworks"></a>frameworks |  A list of framework targets (see [<code>ios_framework</code>](https://github.com/bazelbuild/rules_apple/blob/master/doc/rules-ios.md#ios_framework)) that this target depends on.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="apple_framework_packaging-infoplists"></a>infoplists |  The infoplists for the framework   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="apple_framework_packaging-library_linkopts"></a>library_linkopts |  Internal - A list of strings representing extra flags that are passed to the linker for the underlying library.   | List of strings | optional | <code>[]</code> |
| <a id="apple_framework_packaging-link_dynamic"></a>link_dynamic |  Weather or not if this framework is dynamic<br><br>The default behavior bakes this into the top level app. When false, it's statically linked.   | Boolean | optional | <code>False</code> |
| <a id="apple_framework_packaging-minimum_deployment_os_version"></a>minimum_deployment_os_version |  The bundle identifier of the framework. Currently unused.   | String | optional | <code>""</code> |
| <a id="apple_framework_packaging-minimum_os_version"></a>minimum_os_version |  Internal - currently rules_ios the dict <code>platforms</code>   | String | optional | <code>""</code> |
| <a id="apple_framework_packaging-platform_type"></a>platform_type |  Internal - currently rules_ios uses the dict <code>platforms</code>   | String | optional | <code>""</code> |
| <a id="apple_framework_packaging-platforms"></a>platforms |  A dictionary of platform names to minimum deployment targets. If not given, the framework will be built for the platform it inherits from the target that uses the framework as a dependency.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional | <code>{}</code> |
| <a id="apple_framework_packaging-private_deps"></a>private_deps |  Objc or Swift private rules to be packed by the framework rule   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="apple_framework_packaging-skip_packaging"></a>skip_packaging |  Parts of the framework packaging process to be skipped. Valid values are: - "binary" - "modulemap" - "header" - "private_header" - "swiftmodule" - "swiftdoc"   | List of strings | optional | <code>[]</code> |
| <a id="apple_framework_packaging-stamp"></a>stamp |  -   | Integer | optional | <code>0</code> |
| <a id="apple_framework_packaging-transitive_deps"></a>transitive_deps |  Deps of the deps   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="apple_framework_packaging-vfs"></a>vfs |  Additional VFS for the framework to export   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |


<a id="apple_framework"></a>

## apple_framework

<pre>
apple_framework(<a href="#apple_framework-name">name</a>, <a href="#apple_framework-apple_library">apple_library</a>, <a href="#apple_framework-kwargs">kwargs</a>)
</pre>

Builds and packages an Apple framework.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="apple_framework-name"></a>name |  The name of the framework.   |  none |
| <a id="apple_framework-apple_library"></a>apple_library |  The macro used to package sources into a library.   |  <code>&lt;function apple_library&gt;</code> |
| <a id="apple_framework-kwargs"></a>kwargs |  Arguments passed to the apple_library and apple_framework_packaging rules as appropriate.   |  none |


