<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a id="#ios_application"></a>

## ios_application

<pre>
ios_application(<a href="#ios_application-name">name</a>, <a href="#ios_application-apple_library">apple_library</a>, <a href="#ios_application-infoplists_by_build_setting">infoplists_by_build_setting</a>, <a href="#ios_application-kwargs">kwargs</a>)
</pre>

    Builds and packages an iOS application.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="ios_application-name"></a>name |  The name of the iOS application.   |  none |
| <a id="ios_application-apple_library"></a>apple_library |  The macro used to package sources into a library.   |  <code><function apple_library></code> |
| <a id="ios_application-infoplists_by_build_setting"></a>infoplists_by_build_setting |  A dictionary of infoplists grouped by bazel build setting.<br><br>                             Each value is applied if the respective bazel build setting                              is resolved during the analysis phase.<br><br>                             If '//conditions:default' is not set the value in 'infoplists'                              is set as default.   |  <code>{}</code> |
| <a id="ios_application-kwargs"></a>kwargs |  Arguments passed to the apple_library and ios_application rules as appropriate.   |  none |


