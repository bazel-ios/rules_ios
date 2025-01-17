<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="framework_vfs_overlay"></a>

## framework_vfs_overlay

<pre>
load("@rules_ios//rules:vfs_overlay.doc.bzl", "framework_vfs_overlay")

framework_vfs_overlay(<a href="#framework_vfs_overlay-name">name</a>, <a href="#framework_vfs_overlay-deps">deps</a>, <a href="#framework_vfs_overlay-hdrs">hdrs</a>, <a href="#framework_vfs_overlay-extra_search_paths">extra_search_paths</a>, <a href="#framework_vfs_overlay-framework_name">framework_name</a>, <a href="#framework_vfs_overlay-has_swift">has_swift</a>, <a href="#framework_vfs_overlay-modulemap">modulemap</a>,
                      <a href="#framework_vfs_overlay-private_hdrs">private_hdrs</a>, <a href="#framework_vfs_overlay-swiftmodules">swiftmodules</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="framework_vfs_overlay-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="framework_vfs_overlay-deps"></a>deps |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="framework_vfs_overlay-hdrs"></a>hdrs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="framework_vfs_overlay-extra_search_paths"></a>extra_search_paths |  -   | String | optional |  `""`  |
| <a id="framework_vfs_overlay-framework_name"></a>framework_name |  -   | String | required |  |
| <a id="framework_vfs_overlay-has_swift"></a>has_swift |  Set to True only if there are Swift source files   | Boolean | optional |  `False`  |
| <a id="framework_vfs_overlay-modulemap"></a>modulemap |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="framework_vfs_overlay-private_hdrs"></a>private_hdrs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="framework_vfs_overlay-swiftmodules"></a>swiftmodules |  Everything under a .swiftmodule dir if exists   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |


<a id="make_vfsoverlay"></a>

## make_vfsoverlay

<pre>
load("@rules_ios//rules:vfs_overlay.doc.bzl", "make_vfsoverlay")

make_vfsoverlay(<a href="#make_vfsoverlay-ctx">ctx</a>, <a href="#make_vfsoverlay-hdrs">hdrs</a>, <a href="#make_vfsoverlay-module_map">module_map</a>, <a href="#make_vfsoverlay-private_hdrs">private_hdrs</a>, <a href="#make_vfsoverlay-has_swift">has_swift</a>, <a href="#make_vfsoverlay-swiftmodules">swiftmodules</a>, <a href="#make_vfsoverlay-merge_vfsoverlays">merge_vfsoverlays</a>,
                <a href="#make_vfsoverlay-extra_search_paths">extra_search_paths</a>, <a href="#make_vfsoverlay-output">output</a>, <a href="#make_vfsoverlay-framework_name">framework_name</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="make_vfsoverlay-ctx"></a>ctx |  <p align="center"> - </p>   |  none |
| <a id="make_vfsoverlay-hdrs"></a>hdrs |  <p align="center"> - </p>   |  none |
| <a id="make_vfsoverlay-module_map"></a>module_map |  <p align="center"> - </p>   |  none |
| <a id="make_vfsoverlay-private_hdrs"></a>private_hdrs |  <p align="center"> - </p>   |  none |
| <a id="make_vfsoverlay-has_swift"></a>has_swift |  <p align="center"> - </p>   |  none |
| <a id="make_vfsoverlay-swiftmodules"></a>swiftmodules |  <p align="center"> - </p>   |  `[]` |
| <a id="make_vfsoverlay-merge_vfsoverlays"></a>merge_vfsoverlays |  <p align="center"> - </p>   |  `[]` |
| <a id="make_vfsoverlay-extra_search_paths"></a>extra_search_paths |  <p align="center"> - </p>   |  `None` |
| <a id="make_vfsoverlay-output"></a>output |  <p align="center"> - </p>   |  `None` |
| <a id="make_vfsoverlay-framework_name"></a>framework_name |  <p align="center"> - </p>   |  `None` |


