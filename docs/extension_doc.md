<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="ios_extension"></a>

## ios_extension

<pre>
load("@rules_ios//rules:extension.bzl", "ios_extension")

ios_extension(<a href="#ios_extension-name">name</a>, <a href="#ios_extension-families">families</a>, <a href="#ios_extension-infoplists">infoplists</a>, <a href="#ios_extension-infoplists_by_build_setting">infoplists_by_build_setting</a>, <a href="#ios_extension-xcconfig">xcconfig</a>,
              <a href="#ios_extension-xcconfig_by_build_setting">xcconfig_by_build_setting</a>, <a href="#ios_extension-kwargs">kwargs</a>)
</pre>

Builds and packages an iOS extension.

The docs for ios_extension are at rules_apple
https://github.com/bazelbuild/rules_apple/blob/master/doc/rules-ios.md#ios_extension

Perhaps we can just remove this wrapper longer term.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="ios_extension-name"></a>name |  The name of the iOS extension.   |  none |
| <a id="ios_extension-families"></a>families |  A list of iOS device families the target supports.   |  `["iphone", "ipad"]` |
| <a id="ios_extension-infoplists"></a>infoplists |  A list of Info.plist files to be merged into the extension.   |  `[]` |
| <a id="ios_extension-infoplists_by_build_setting"></a>infoplists_by_build_setting |  A dictionary of infoplists grouped by bazel build setting.<br><br>Each value is applied if the respective bazel build setting is resolved during the analysis phase.<br><br>If '//conditions:default' is not set the value in 'infoplists' is set as default.   |  `{}` |
| <a id="ios_extension-xcconfig"></a>xcconfig |  A dictionary of xcconfigs to be applied to the extension by default.   |  `{}` |
| <a id="ios_extension-xcconfig_by_build_setting"></a>xcconfig_by_build_setting |  A dictionary of xcconfigs grouped by bazel build setting.<br><br>Each value is applied if the respective bazel build setting is resolved during the analysis phase.<br><br>If '//conditions:default' is not set the value in 'xcconfig' is set as default.   |  `{}` |
| <a id="ios_extension-kwargs"></a>kwargs |  Arguments passed to the ios_extension rule as appropriate.   |  none |


