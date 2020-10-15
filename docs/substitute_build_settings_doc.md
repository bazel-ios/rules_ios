<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a id="#substitute_build_settings"></a>

## substitute_build_settings

<pre>
substitute_build_settings(<a href="#substitute_build_settings-name">name</a>, <a href="#substitute_build_settings-source">source</a>, <a href="#substitute_build_settings-variables">variables</a>)
</pre>

Does Xcode-style build setting substitutions into the given source file.


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="substitute_build_settings-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="substitute_build_settings-source"></a>source |  The file to be expanded   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
| <a id="substitute_build_settings-variables"></a>variables |  A mapping of settings to their values to be expanded. The setting names should not include <code>$</code>s   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a> | optional | {} |


