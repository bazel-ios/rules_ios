<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a id="#extend_modulemap"></a>

## extend_modulemap

<pre>
extend_modulemap(<a href="#extend_modulemap-name">name</a>, <a href="#extend_modulemap-destination">destination</a>, <a href="#extend_modulemap-module_name">module_name</a>, <a href="#extend_modulemap-source">source</a>, <a href="#extend_modulemap-swift_header">swift_header</a>)
</pre>

Extends a modulemap with a Swift submodule

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="extend_modulemap-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="extend_modulemap-destination"></a>destination |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional |  |
| <a id="extend_modulemap-module_name"></a>module_name |  -   | String | required |  |
| <a id="extend_modulemap-source"></a>source |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="extend_modulemap-swift_header"></a>swift_header |  -   | String | optional | "" |


<a id="#write_file"></a>

## write_file

<pre>
write_file(<a href="#write_file-name">name</a>, <a href="#write_file-content">content</a>, <a href="#write_file-destination">destination</a>)
</pre>

Writes out a file verbatim

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="write_file-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="write_file-content"></a>content |  -   | String | required |  |
| <a id="write_file-destination"></a>destination |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |


<a id="#PrivateHeadersInfo"></a>

## PrivateHeadersInfo

<pre>
PrivateHeadersInfo(<a href="#PrivateHeadersInfo-headers">headers</a>)
</pre>

Propagates private headers, so they can be accessed if necessary

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="PrivateHeadersInfo-headers"></a>headers |  Private headers    |


<a id="#apple_library"></a>

## apple_library

<pre>
apple_library(<a href="#apple_library-name">name</a>, <a href="#apple_library-library_tools">library_tools</a>, <a href="#apple_library-export_private_headers">export_private_headers</a>, <a href="#apple_library-namespace_is_module_name">namespace_is_module_name</a>,
              <a href="#apple_library-default_xcconfig_name">default_xcconfig_name</a>, <a href="#apple_library-xcconfig">xcconfig</a>, <a href="#apple_library-xcconfig_by_build_setting">xcconfig_by_build_setting</a>, <a href="#apple_library-kwargs">kwargs</a>)
</pre>

Create libraries for native source code on Apple platforms.

Automatically handles mixed-source libraries and comes with
reasonable defaults that mimic Xcode's behavior.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="apple_library-name"></a>name |  The base name for all of the underlying targets.   |  none |
| <a id="apple_library-library_tools"></a>library_tools |  An optional dictionary containing overrides for                 default behaviors.   |  <code>{}</code> |
| <a id="apple_library-export_private_headers"></a>export_private_headers |  Whether private headers should be exported via                         a <code>PrivateHeadersInfo</code> provider.   |  <code>True</code> |
| <a id="apple_library-namespace_is_module_name"></a>namespace_is_module_name |  Whether the module name should be used as the                           namespace for header imports, instead of the target name.   |  <code>True</code> |
| <a id="apple_library-default_xcconfig_name"></a>default_xcconfig_name |  The name of a default xcconfig to be applied to this target.   |  <code>None</code> |
| <a id="apple_library-xcconfig"></a>xcconfig |  A dictionary of Xcode build settings to be applied to this target in the           form of different <code>copt</code> attributes.   |  <code>{}</code> |
| <a id="apple_library-xcconfig_by_build_setting"></a>xcconfig_by_build_setting |  A dictionary of Xcode build settings grouped by bazel build settings,                            these will be applied (and override any value in 'xcconfig') if the respective                            bazel build setting is resolved in the analysis phase   |  <code>{}</code> |
| <a id="apple_library-kwargs"></a>kwargs |  keyword arguments.   |  none |


