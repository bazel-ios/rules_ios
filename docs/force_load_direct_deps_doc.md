<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="force_load_direct_deps"></a>

## force_load_direct_deps

<pre>
force_load_direct_deps(<a href="#force_load_direct_deps-name">name</a>, <a href="#force_load_direct_deps-deps">deps</a>, <a href="#force_load_direct_deps-minimum_os_version">minimum_os_version</a>, <a href="#force_load_direct_deps-platform_type">platform_type</a>, <a href="#force_load_direct_deps-should_force_load">should_force_load</a>)
</pre>

A rule to link with `-force_load` for direct`deps`

ld has different behavior when loading members of a static library VS objects
as far as visibility. Under `-dynamic`
- linked _swift object files_ can have public visibility
- symbols from _swift static libraries_ are omitted unless used, and not
visible otherwise

By using `-force_load`, we can load static libraries in the attributes of an
application's direct depenencies. These args need go at the _front_ of the
linker invocation otherwise these arguments don't work with lds logic.

Why not put it into `rules_apple`? Ideally it could be, and perhaps consider a
PR to there .The underlying java rule, `AppleBinary.linkMultiArchBinary`
places `extraLinkopts` at the end of the linker invocation. At the time of
writing these args need to go into the current rule context where
`AppleBinary.linkMultiArchBinary` is called.

One use case of this is that iOS developers want to load above mentioned
symbols from applications. Another alternate could be to create an aspect,
that actually generates a different application and linker invocation instead
of force loading symbols. This could be more complicated from an integration
perspective so it isn't used.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="force_load_direct_deps-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="force_load_direct_deps-deps"></a>deps |  Deps   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="force_load_direct_deps-minimum_os_version"></a>minimum_os_version |  Internal - currently rules_ios the dict `platforms`   | String | optional |  `""`  |
| <a id="force_load_direct_deps-platform_type"></a>platform_type |  Internal - currently rules_ios uses the dict `platforms`   | String | optional |  `""`  |
| <a id="force_load_direct_deps-should_force_load"></a>should_force_load |  Allows parametrically enabling the functionality in this rule.   | Boolean | optional |  `True`  |


