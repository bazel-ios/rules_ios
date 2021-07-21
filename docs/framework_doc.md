<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a id="#apple_framework_packaging"></a>

## apple_framework_packaging

<pre>
apple_framework_packaging(<a href="#apple_framework_packaging-name">name</a>, <a href="#apple_framework_packaging-bundle_extension">bundle_extension</a>, <a href="#apple_framework_packaging-bundle_id">bundle_id</a>, <a href="#apple_framework_packaging-deps">deps</a>, <a href="#apple_framework_packaging-framework_name">framework_name</a>,
                          <a href="#apple_framework_packaging-minimum_os_version">minimum_os_version</a>, <a href="#apple_framework_packaging-platform_type">platform_type</a>, <a href="#apple_framework_packaging-platforms">platforms</a>, <a href="#apple_framework_packaging-skip_packaging">skip_packaging</a>,
                          <a href="#apple_framework_packaging-transitive_deps">transitive_deps</a>, <a href="#apple_framework_packaging-vfs">vfs</a>)
</pre>

Packages compiled code into an Apple .framework package

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="apple_framework_packaging-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="apple_framework_packaging-bundle_extension"></a>bundle_extension |  The extension of the bundle, defaults to "framework".   | String | optional | "framework" |
| <a id="apple_framework_packaging-bundle_id"></a>bundle_id |  The bundle identifier of the framework. Currently unused.   | String | optional | "" |
| <a id="apple_framework_packaging-deps"></a>deps |  Objc or Swift rules to be packed by the framework rule   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |
| <a id="apple_framework_packaging-framework_name"></a>framework_name |  Name of the framework, usually the same as the module name   | String | required |  |
| <a id="apple_framework_packaging-minimum_os_version"></a>minimum_os_version |  Internal - currently rules_ios the dict <code>platforms</code>   | String | optional | "" |
| <a id="apple_framework_packaging-platform_type"></a>platform_type |  Internal - currently rules_ios uses the dict <code>platforms</code>   | String | optional | "" |
| <a id="apple_framework_packaging-platforms"></a>platforms |  A dictionary of platform names to minimum deployment targets. If not given, the framework will be built for the platform it inherits from the target that uses the framework as a dependency.   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a> | optional | {} |
| <a id="apple_framework_packaging-skip_packaging"></a>skip_packaging |  Parts of the framework packaging process to be skipped. Valid values are: - "binary" - "modulemap" - "header" - "private_header" - "swiftmodule" - "swiftdoc"   | List of strings | optional | [] |
| <a id="apple_framework_packaging-transitive_deps"></a>transitive_deps |  Deps of the deps   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |
| <a id="apple_framework_packaging-vfs"></a>vfs |  Additional VFS for the framework to export   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |


<a id="#apple_framework"></a>

## apple_framework

<pre>
apple_framework(<a href="#apple_framework-name">name</a>, <a href="#apple_framework-apple_library">apple_library</a>, <a href="#apple_framework-kwargs">kwargs</a>)
</pre>

Builds and packages an Apple framework.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="apple_framework-name"></a>name |  The name of the framework.   |  none |
| <a id="apple_framework-apple_library"></a>apple_library |  The macro used to package sources into a library.   |  <code><function apple_library></code> |
| <a id="apple_framework-kwargs"></a>kwargs |  Arguments passed to the apple_library and apple_framework_packaging rules as appropriate.   |  none |


