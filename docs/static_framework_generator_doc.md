<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a id="#static_framework_generator_test"></a>

## static_framework_generator_test

<pre>
static_framework_generator_test(<a href="#static_framework_generator_test-name">name</a>, <a href="#static_framework_generator_test-destination_relative_to_package">destination_relative_to_package</a>,
                                <a href="#static_framework_generator_test-destination_relative_to_workspace">destination_relative_to_workspace</a>, <a href="#static_framework_generator_test-targets">targets</a>)
</pre>

This generator moves the frameworks artifacts produced by Bazel to a location out of the cache.
It is intended to be used as a tool to ease compatibility with other build systems.

For example, it would be possible to integrate with cocoapods as follows:
1- Build targets with Bazel
2- Use this rule to generate frameworks for them
3- Generate podspec files containing the generated frameworks as vendored_frameworks, so they can be 
   integrated in a cocoapods setup, substituting their source code counterparts (useful to cut build time)


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="static_framework_generator_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="static_framework_generator_test-destination_relative_to_package"></a>destination_relative_to_package |  Destination folder for the generated frameworks, relative to the package   | String | optional | "" |
| <a id="static_framework_generator_test-destination_relative_to_workspace"></a>destination_relative_to_workspace |  Destination folder for the generated frameworks, relative to the workspace   | String | optional | "static_framework_generator" |
| <a id="static_framework_generator_test-targets"></a>targets |  The list of targets to use for generating the frameworks   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |


<a id="#static_framework_generator"></a>

## static_framework_generator

<pre>
static_framework_generator(<a href="#static_framework_generator-kwargs">kwargs</a>)
</pre>

    A wrapper around static_framework_generator_test which disables the sandbox

This rule writes its output to the WORKSPACE, which is a location out of the sandbox:
in order for bazel to allow that, sandbox must be disabled


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="static_framework_generator-kwargs"></a>kwargs |  same as the parameters for static_framework_generator_test   |  none |


