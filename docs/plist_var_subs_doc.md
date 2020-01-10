<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#plist_var_subs"></a>

## plist_var_subs

<pre>
plist_var_subs(<a href="#plist_var_subs-name">name</a>, <a href="#plist_var_subs-plist">plist</a>, <a href="#plist_var_subs-variables">variables</a>)
</pre>

Does Xcode-style build setting substitutions into the given source file.


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| plist |  The file to be expanded   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
| variables |  A mapping of settings to their values to be expanded. The setting names should not include <code>$</code>s   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a> | optional | {} |


