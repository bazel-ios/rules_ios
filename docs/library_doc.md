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
| content |  -   | String | optional | "" |
| destination |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |


<a name="#PrivateHeaders"></a>

## PrivateHeaders

<pre>
PrivateHeaders(<a href="#PrivateHeaders-headers">headers</a>)
</pre>

Propagates private headers, so they can be accessed if necessary

**FIELDS**


| Name  | Description |
| :-------------: | :-------------: |
| headers |  Private headers    |


<a name="#apple_library"></a>

## apple_library

<pre>
apple_library(<a href="#apple_library-name">name</a>, <a href="#apple_library-library_tools">library_tools</a>, <a href="#apple_library-export_private_headers">export_private_headers</a>, <a href="#apple_library-kwargs">kwargs</a>)
</pre>

Create libraries for native source code on Apple platforms.

Automatically handles mixed-source libraries and comes with
reasonable defaults that mimic Xcode's behavior.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  The base name for all of the underlying targets.   |  none |
| library_tools |  An optional dictionary containing overrides for                 default behaviors.   |  <code>{}</code> |
| export_private_headers |  Whether private headers should be exported via                         a <code>PrivateHeaders</code> provider.   |  <code>True</code> |
| kwargs |  <p align="center"> - </p>   |  none |


<a name="#generate_resource_bundles"></a>

## generate_resource_bundles

<pre>
generate_resource_bundles(<a href="#generate_resource_bundles-name">name</a>, <a href="#generate_resource_bundles-library_tools">library_tools</a>, <a href="#generate_resource_bundles-module_name">module_name</a>, <a href="#generate_resource_bundles-resource_bundles">resource_bundles</a>, <a href="#generate_resource_bundles-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  <p align="center"> - </p>   |  none |
| library_tools |  <p align="center"> - </p>   |  none |
| module_name |  <p align="center"> - </p>   |  none |
| resource_bundles |  <p align="center"> - </p>   |  none |
| kwargs |  <p align="center"> - </p>   |  none |


<a name="#write_modulemap"></a>

## write_modulemap

<pre>
write_modulemap(<a href="#write_modulemap-name">name</a>, <a href="#write_modulemap-library_tools">library_tools</a>, <a href="#write_modulemap-umbrella_header">umbrella_header</a>, <a href="#write_modulemap-public_headers">public_headers</a>, <a href="#write_modulemap-private_headers">private_headers</a>, <a href="#write_modulemap-module_name">module_name</a>,
                <a href="#write_modulemap-framework">framework</a>, <a href="#write_modulemap-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  <p align="center"> - </p>   |  none |
| library_tools |  <p align="center"> - </p>   |  none |
| umbrella_header |  <p align="center"> - </p>   |  <code>None</code> |
| public_headers |  <p align="center"> - </p>   |  <code>[]</code> |
| private_headers |  <p align="center"> - </p>   |  <code>[]</code> |
| module_name |  <p align="center"> - </p>   |  <code>None</code> |
| framework |  <p align="center"> - </p>   |  <code>False</code> |
| kwargs |  <p align="center"> - </p>   |  none |


<a name="#write_umbrella_header"></a>

## write_umbrella_header

<pre>
write_umbrella_header(<a href="#write_umbrella_header-name">name</a>, <a href="#write_umbrella_header-library_tools">library_tools</a>, <a href="#write_umbrella_header-public_headers">public_headers</a>, <a href="#write_umbrella_header-private_headers">private_headers</a>, <a href="#write_umbrella_header-module_name">module_name</a>, <a href="#write_umbrella_header-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  <p align="center"> - </p>   |  none |
| library_tools |  <p align="center"> - </p>   |  none |
| public_headers |  <p align="center"> - </p>   |  <code>[]</code> |
| private_headers |  <p align="center"> - </p>   |  <code>[]</code> |
| module_name |  <p align="center"> - </p>   |  <code>None</code> |
| kwargs |  <p align="center"> - </p>   |  none |


