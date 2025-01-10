<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="import_middleman"></a>

## import_middleman

<pre>
load("@rules_ios//rules:import_middleman.bzl", "import_middleman")

import_middleman(<a href="#import_middleman-name">name</a>, <a href="#import_middleman-deps">deps</a>, <a href="#import_middleman-test_deps">test_deps</a>, <a href="#import_middleman-update_in_place">update_in_place</a>)
</pre>

This rule adds the ability to update the Mach-o header on imported
libraries and frameworks to get arm64 binaires running on Apple silicon
simulator. For rules_ios, it's added in `app.bzl` and `test.bzl`

Why bother doing this? Well some apps have many dependencies which could take
along time on vendors or other parties to update. Because the M1 chip has the
same ISA as ARM64, most binaries will run transparently. Most iOS developers
code is high level enough and isn't specifc to a device or simulator. There are
many caveats and eceptions but getting it running is better than nothing. ( e.g.
`TARGET_OS_SIMULATOR` )

This solves the problem at the build system level with the power of bazel. The
idea is pretty straight forward:
1. collect all imported paths
2. update the macho headers with Apples vtool and arm64-to-sim
3. update the linker invocation to use the new libs

Now it updates all of the inputs automatically - the action can be taught to do
all of this conditionally if necessary.

Note: The action happens in a rule for a few reasons.  This has an interesting
propery: you get a single path for framework lookups at linktime. Perhaps this
can be updated to work without the other behavior

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="import_middleman-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="import_middleman-deps"></a>deps |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="import_middleman-test_deps"></a>test_deps |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="import_middleman-update_in_place"></a>update_in_place |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_ios//tools/m1_utils:update_in_place"`  |


<a id="find_imports"></a>

## find_imports

<pre>
load("@rules_ios//rules:import_middleman.bzl", "find_imports")

find_imports(<a href="#find_imports-name">name</a>)
</pre>

Internal aspect for the `import_middleman` see below for a description.

**ASPECT ATTRIBUTES**


| Name | Type |
| :------------- | :------------- |
| transitve_deps| String |
| deps| String |


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="find_imports-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |


