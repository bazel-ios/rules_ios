<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Defines macros for working with plist files.

<a id="process_infoplists"></a>

## process_infoplists

<pre>
process_infoplists(<a href="#process_infoplists-name">name</a>, <a href="#process_infoplists-infoplists">infoplists</a>, <a href="#process_infoplists-infoplists_by_build_setting">infoplists_by_build_setting</a>, <a href="#process_infoplists-xcconfig">xcconfig</a>,
                   <a href="#process_infoplists-xcconfig_by_build_setting">xcconfig_by_build_setting</a>)
</pre>

Constructs substituted_plists by substituting build settings from an xcconfig dict into the variables of a plist.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="process_infoplists-name"></a>name |  The name of the target that the plist is being generated for.   |  none |
| <a id="process_infoplists-infoplists"></a>infoplists |  The plist files to be manipulated   |  none |
| <a id="process_infoplists-infoplists_by_build_setting"></a>infoplists_by_build_setting |  A dictionary of infoplists keyed by config_setting, merged with infoplists created here.   |  none |
| <a id="process_infoplists-xcconfig"></a>xcconfig |  the default build settings to expand the infoplists with   |  none |
| <a id="process_infoplists-xcconfig_by_build_setting"></a>xcconfig_by_build_setting |  the build settings grouped by config_setting to expand the infoplists with   |  none |

**RETURNS**

A selectable dict of the substituted_plists grouped by config_setting


<a id="substituted_plist"></a>

## substituted_plist

<pre>
substituted_plist(<a href="#substituted_plist-name">name</a>, <a href="#substituted_plist-plist">plist</a>, <a href="#substituted_plist-xcconfig">xcconfig</a>)
</pre>

Substitutes build settings from an xcconfig dict into the variables of a plist.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="substituted_plist-name"></a>name |  The name of the plist.   |  none |
| <a id="substituted_plist-plist"></a>plist |  The plist file to substitute into.   |  none |
| <a id="substituted_plist-xcconfig"></a>xcconfig |  The xcconfig variables for substitution.   |  none |

**RETURNS**

The plist target with the substituted variables.


<a id="write_info_plists_if_needed"></a>

## write_info_plists_if_needed

<pre>
write_info_plists_if_needed(<a href="#write_info_plists_if_needed-name">name</a>, <a href="#write_info_plists_if_needed-plists">plists</a>)
</pre>

Writes info plists for a bundle if needed.

Given a list of infoplists, will write out any plists that are passed as a
dict, and will add a default app Info.plist if no non-dict plists are passed.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="write_info_plists_if_needed-name"></a>name |  The name of the bundle target these infoplists are for.   |  none |
| <a id="write_info_plists_if_needed-plists"></a>plists |  A list of either labels or dicts.   |  none |

**RETURNS**

A list of labels to the generated Info.plist files.


