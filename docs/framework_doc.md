<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#apple_framework_packaging"></a>

## apple_framework_packaging

<pre>
apple_framework_packaging(<a href="#apple_framework_packaging-name">name</a>, <a href="#apple_framework_packaging-deps">deps</a>, <a href="#apple_framework_packaging-framework_name">framework_name</a>, <a href="#apple_framework_packaging-transitive_deps">transitive_deps</a>)
</pre>

Packages compiled code into an Apple .framework package

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| deps |  Objc or Swift rules to be packed by the framework rule   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |
| framework_name |  Name of the framework, usually the same as the module name   | String | required |  |
| transitive_deps |  Deps of the deps   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |


<a name="#apple_framework"></a>

## apple_framework

<pre>
apple_framework(<a href="#apple_framework-name">name</a>, <a href="#apple_framework-apple_library">apple_library</a>, <a href="#apple_framework-kwargs">kwargs</a>)
</pre>

    Builds and packages an Apple framework.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  The name of the framework.   |  none |
| apple_library |  The macro used to package sources into a library.   |  <code><function apple_library></code> |
| kwargs |  Arguments passed to the apple_library and apple_framework_packaging rules as appropriate.   |  none |


