<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="ios_app_clip"></a>

## ios_app_clip

<pre>
ios_app_clip(<a href="#ios_app_clip-name">name</a>, <a href="#ios_app_clip-families">families</a>, <a href="#ios_app_clip-infoplists">infoplists</a>, <a href="#ios_app_clip-infoplists_by_build_setting">infoplists_by_build_setting</a>, <a href="#ios_app_clip-xcconfig">xcconfig</a>,
             <a href="#ios_app_clip-xcconfig_by_build_setting">xcconfig_by_build_setting</a>, <a href="#ios_app_clip-kwargs">kwargs</a>)
</pre>

Builds and packages an iOS App Clip.

The docs for app_clip are at rules_apple
https://github.com/bazelbuild/rules_apple/blob/master/doc/rules-ios.md#ios_app_clip


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="ios_app_clip-name"></a>name |  The name of the iOS app clip.   |  none |
| <a id="ios_app_clip-families"></a>families |  A list of iOS device families the target supports.   |  `["iphone", "ipad"]` |
| <a id="ios_app_clip-infoplists"></a>infoplists |  A list of Info.plist files to be merged into the app clip.   |  `[]` |
| <a id="ios_app_clip-infoplists_by_build_setting"></a>infoplists_by_build_setting |  A dictionary of infoplists grouped by bazel build setting.<br><br>Each value is applied if the respective bazel build setting is resolved during the analysis phase.<br><br>If '//conditions:default' is not set the value in 'infoplists' is set as default.   |  `{}` |
| <a id="ios_app_clip-xcconfig"></a>xcconfig |  A dictionary of xcconfigs to be applied to the app clip by default.   |  `{}` |
| <a id="ios_app_clip-xcconfig_by_build_setting"></a>xcconfig_by_build_setting |  A dictionary of xcconfigs grouped by bazel build setting.<br><br>Each value is applied if the respective bazel build setting is resolved during the analysis phase.<br><br>If '//conditions:default' is not set the value in 'xcconfig' is set as default.   |  `{}` |
| <a id="ios_app_clip-kwargs"></a>kwargs |  Arguments passed to the ios_app_clip rule as appropriate.   |  none |


