<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a id="#info_plists_by_setting"></a>

## info_plists_by_setting

<pre>
info_plists_by_setting(<a href="#info_plists_by_setting-name">name</a>, <a href="#info_plists_by_setting-infoplists_by_build_setting">infoplists_by_build_setting</a>, <a href="#info_plists_by_setting-default_infoplists">default_infoplists</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="info_plists_by_setting-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="info_plists_by_setting-infoplists_by_build_setting"></a>infoplists_by_build_setting |  <p align="center"> - </p>   |  none |
| <a id="info_plists_by_setting-default_infoplists"></a>default_infoplists |  <p align="center"> - </p>   |  none |


<a id="#write_info_plists_if_needed"></a>

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


