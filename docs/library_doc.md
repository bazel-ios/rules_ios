<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#extend_modulemap"></a>

## extend_modulemap

<pre>
extend_modulemap(<a href="#extend_modulemap-name">name</a>, <a href="#extend_modulemap-destination">destination</a>, <a href="#extend_modulemap-module_name">module_name</a>, <a href="#extend_modulemap-source">source</a>, <a href="#extend_modulemap-swift_header">swift_header</a>)
</pre>

Extends a modulemap with a Swift submodule

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| destination |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| module_name |  -   | String | required |  |
| source |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| swift_header |  -   | String | optional | "" |


<a name="#write_file"></a>

## write_file

<pre>
write_file(<a href="#write_file-name">name</a>, <a href="#write_file-content">content</a>, <a href="#write_file-destination">destination</a>)
</pre>

Writes out a file verbatim

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| content |  -   | String | required |  |
| destination |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |


<a name="#PrivateHeadersInfo"></a>

## PrivateHeadersInfo

<pre>
PrivateHeadersInfo(<a href="#PrivateHeadersInfo-headers">headers</a>)
</pre>

Propagates private headers, so they can be accessed if necessary

**FIELDS**


| Name  | Description |
| :-------------: | :-------------: |
| headers |  Private headers    |


<a name="#apple_library"></a>

## apple_library

<pre>
apple_library(<a href="#apple_library-name">name</a>, <a href="#apple_library-library_tools">library_tools</a>, <a href="#apple_library-export_private_headers">export_private_headers</a>, <a href="#apple_library-namespace_is_module_name">namespace_is_module_name</a>,
              <a href="#apple_library-default_xcconfig_name">default_xcconfig_name</a>, <a href="#apple_library-xcconfig">xcconfig</a>, <a href="#apple_library-kwargs">kwargs</a>)
</pre>

Create libraries for native source code on Apple platforms.

Automatically handles mixed-source libraries and comes with
reasonable defaults that mimic Xcode's behavior.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  The base name for all of the underlying targets.   |  none |
| library_tools |  An optional dictionary containing overrides for                 default behaviors.   |  <code>{}</code> |
| export_private_headers |  Whether private headers should be exported via                         a <code>PrivateHeadersInfo</code> provider.   |  <code>True</code> |
| namespace_is_module_name |  Whether the module name should be used as the                           namespace for header imports, instead of the target name.   |  <code>True</code> |
| default_xcconfig_name |  The name of a default xcconfig to be applied to this target.   |  <code>None</code> |
| xcconfig |  A dictionary of Xcode build settings to be applied to this target in the           form of different <code>copt</code> attributes.   |  <code>{}</code> |
| kwargs |  keyword arguments.   |  none |


