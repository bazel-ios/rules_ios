<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#ios_application"></a>

## ios_application

<pre>
ios_application(<a href="#ios_application-name">name</a>, <a href="#ios_application-apple_library">apple_library</a>, <a href="#ios_application-kwargs">kwargs</a>)
</pre>

    Builds and packages an iOS application.

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  The name of the iOS application.   |  none |
| apple_library |  The macro used to package sources into a library.   |  <code><function apple_library></code> |
| kwargs |  Arguments passed to the apple_library and ios_application rules as appropriate.   |  none |


<a name="#write_info_plists_if_needed"></a>

## write_info_plists_if_needed

<pre>
write_info_plists_if_needed(<a href="#write_info_plists_if_needed-name">name</a>, <a href="#write_info_plists_if_needed-plists">plists</a>)
</pre>

    Writes info plists for an app if needed.

Given a list of infoplists, will write out any plists that are passed as a
dict, and will add a default app Info.plist if no non-dict plists are passed.


**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  The name of the app target these infoplists are for.   |  none |
| plists |  A list of either labels or dicts.   |  none |


