<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="build_setting_name"></a>

## build_setting_name

<pre>
load("@rules_ios//rules:xcconfig.doc.bzl", "build_setting_name")

build_setting_name(<a href="#build_setting_name-build_setting">build_setting</a>)
</pre>

Returns the name of a given bazel build setting from the fully-qualified label

Fails if 'build_setting' is not in the expected format


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="build_setting_name-build_setting"></a>build_setting |  The fully-qualified label for a bazel build setting, e.g., '@repo_name//path/to/package:target_name'   |  none |

**RETURNS**

The string 'target_name' in '@repo_name//path/to/package:target_name'


<a id="copts_by_build_setting_with_defaults"></a>

## copts_by_build_setting_with_defaults

<pre>
load("@rules_ios//rules:xcconfig.doc.bzl", "copts_by_build_setting_with_defaults")

copts_by_build_setting_with_defaults(<a href="#copts_by_build_setting_with_defaults-xcconfig">xcconfig</a>, <a href="#copts_by_build_setting_with_defaults-fetch_default_xcconfig">fetch_default_xcconfig</a>, <a href="#copts_by_build_setting_with_defaults-xcconfig_by_build_setting">xcconfig_by_build_setting</a>)
</pre>

Creates a struct containing different configurable copts

Each returned copts is a 'select()' statement keyed by the bazel build settings in 'xcconfig_by_build_setting' and each
resolved value is the result of merging 'xcconfig' with the respective build setting xcconfig and applying the
default values from 'fetch_default_xcconfig' if necessary.

For the default value to be resolved ('//conditions:default') this macro follows the same logic described above without
the 'merging' step, so 'xcconfig' plus default values from 'fetch_default_xcconfig' if necessary.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="copts_by_build_setting_with_defaults-xcconfig"></a>xcconfig |  A dictionary of Xcode build settings to be converted to different `copt` attributes.   |  `{}` |
| <a id="copts_by_build_setting_with_defaults-fetch_default_xcconfig"></a>fetch_default_xcconfig |  A dictionary of default Xcode build settings to be applied for the keys that are not set.   |  `{}` |
| <a id="copts_by_build_setting_with_defaults-xcconfig_by_build_setting"></a>xcconfig_by_build_setting |  A dictionary where the keys are build settings names and the values are the respective dictionaries of Xcode build settings   |  `{}` |

**RETURNS**

Struct with different copts behind 'select()' statements


<a id="merge_xcconfigs"></a>

## merge_xcconfigs

<pre>
load("@rules_ios//rules:xcconfig.doc.bzl", "merge_xcconfigs")

merge_xcconfigs(<a href="#merge_xcconfigs-xcconfigs">xcconfigs</a>)
</pre>

Merges a list of xcconfigs into a single dictionary

Overrides keys from the first xcconfig with the values from the latest one if they match.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="merge_xcconfigs-xcconfigs"></a>xcconfigs |  A list of dictionaries of Xcode build settings   |  none |

**RETURNS**

A dictionary of Xcode build settings


