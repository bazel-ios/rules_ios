<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Library rules

<a id="extend_modulemap"></a>

## extend_modulemap

<pre>
extend_modulemap(<a href="#extend_modulemap-name">name</a>, <a href="#extend_modulemap-destination">destination</a>, <a href="#extend_modulemap-module_name">module_name</a>, <a href="#extend_modulemap-source">source</a>, <a href="#extend_modulemap-swift_header">swift_header</a>)
</pre>

Extends a modulemap with a Swift submodule

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="extend_modulemap-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="extend_modulemap-destination"></a>destination |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  |
| <a id="extend_modulemap-module_name"></a>module_name |  -   | String | required |  |
| <a id="extend_modulemap-source"></a>source |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="extend_modulemap-swift_header"></a>swift_header |  -   | String | optional |  `""`  |


<a id="PrivateHeadersInfo"></a>

## PrivateHeadersInfo

<pre>
PrivateHeadersInfo(<a href="#PrivateHeadersInfo-headers">headers</a>)
</pre>

Propagates private headers, so they can be accessed if necessary

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="PrivateHeadersInfo-headers"></a>headers |  Private headers    |


<a id="apple_library"></a>

## apple_library

<pre>
apple_library(<a href="#apple_library-name">name</a>, <a href="#apple_library-library_tools">library_tools</a>, <a href="#apple_library-export_private_headers">export_private_headers</a>, <a href="#apple_library-namespace_is_module_name">namespace_is_module_name</a>,
              <a href="#apple_library-default_xcconfig_name">default_xcconfig_name</a>, <a href="#apple_library-xcconfig">xcconfig</a>, <a href="#apple_library-xcconfig_by_build_setting">xcconfig_by_build_setting</a>, <a href="#apple_library-objc_defines">objc_defines</a>, <a href="#apple_library-swift_defines">swift_defines</a>,
              <a href="#apple_library-kwargs">kwargs</a>)
</pre>

Create libraries for native source code on Apple platforms.

Automatically handles mixed-source libraries and comes with
reasonable defaults that mimic Xcode's behavior.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="apple_library-name"></a>name |  The base name for all of the underlying targets.   |  none |
| <a id="apple_library-library_tools"></a>library_tools |  An optional dictionary containing overrides for default behaviors.   |  `{}` |
| <a id="apple_library-export_private_headers"></a>export_private_headers |  Whether private headers should be exported via a `PrivateHeadersInfo` provider.   |  `True` |
| <a id="apple_library-namespace_is_module_name"></a>namespace_is_module_name |  Whether the module name should be used as the namespace for header imports, instead of the target name.   |  `True` |
| <a id="apple_library-default_xcconfig_name"></a>default_xcconfig_name |  The name of a default xcconfig to be applied to this target.   |  `None` |
| <a id="apple_library-xcconfig"></a>xcconfig |  A dictionary of Xcode build settings to be applied to this target in the form of different `copt` attributes.   |  `{}` |
| <a id="apple_library-xcconfig_by_build_setting"></a>xcconfig_by_build_setting |  A dictionary of Xcode build settings grouped by bazel build setting.<br><br>Each value is applied (overriding any matching setting in 'xcconfig') if the respective bazel build setting is resolved during the analysis phase.   |  `{}` |
| <a id="apple_library-objc_defines"></a>objc_defines |  A list of Objective-C defines to add to the compilation command line. They should be in the form KEY=VALUE or simply KEY and are passed not only to the compiler for this target (as copts are) but also to all objc_ dependers of this target.   |  `[]` |
| <a id="apple_library-swift_defines"></a>swift_defines |  A list of Swift defines to add to the compilation command line. Swift defines do not have values, so strings in this list should be simple identifiers and not KEY=VALUE pairs. (only expections are KEY=1 and KEY=0). These flags are added for the target and every target that depends on it.   |  `[]` |
| <a id="apple_library-kwargs"></a>kwargs |  keyword arguments.   |  none |

**RETURNS**

Struct with a bunch of info


