<!-- Generated with Stardoc: http://skydoc.bazel.build -->

 Xcode Project Generation Logic

<a id="#xcodeproj"></a>

## xcodeproj

<pre>
xcodeproj(<a href="#xcodeproj-name">name</a>, <a href="#xcodeproj-additional_bazel_build_options">additional_bazel_build_options</a>, <a href="#xcodeproj-additional_files">additional_files</a>, <a href="#xcodeproj-additional_lldb_settings">additional_lldb_settings</a>,
          <a href="#xcodeproj-additional_post_actions">additional_post_actions</a>, <a href="#xcodeproj-additional_pre_actions">additional_pre_actions</a>, <a href="#xcodeproj-additional_prebuild_script">additional_prebuild_script</a>,
          <a href="#xcodeproj-additional_scheme_infos">additional_scheme_infos</a>, <a href="#xcodeproj-bazel_execution_log_enabled">bazel_execution_log_enabled</a>, <a href="#xcodeproj-bazel_path">bazel_path</a>, <a href="#xcodeproj-bazel_profile_enabled">bazel_profile_enabled</a>,
          <a href="#xcodeproj-build_wrapper">build_wrapper</a>, <a href="#xcodeproj-clang_stub">clang_stub</a>, <a href="#xcodeproj-configs">configs</a>, <a href="#xcodeproj-deps">deps</a>, <a href="#xcodeproj-generate_schemes_for_product_types">generate_schemes_for_product_types</a>,
          <a href="#xcodeproj-include_transitive_targets">include_transitive_targets</a>, <a href="#xcodeproj-index_import">index_import</a>, <a href="#xcodeproj-infoplist_stub">infoplist_stub</a>, <a href="#xcodeproj-installer">installer</a>, <a href="#xcodeproj-ld_stub">ld_stub</a>, <a href="#xcodeproj-output_path">output_path</a>,
          <a href="#xcodeproj-output_processor">output_processor</a>, <a href="#xcodeproj-print_json_leaf_nodes">print_json_leaf_nodes</a>, <a href="#xcodeproj-project_attributes_overrides">project_attributes_overrides</a>, <a href="#xcodeproj-project_name">project_name</a>,
          <a href="#xcodeproj-provide_build_settings_from_target_for_pre_post_actions">provide_build_settings_from_target_for_pre_post_actions</a>, <a href="#xcodeproj-scheme_existing_envvar_overrides">scheme_existing_envvar_overrides</a>,
          <a href="#xcodeproj-swiftc_stub">swiftc_stub</a>)
</pre>

Generates a Xcode project file (.xcodeproj) with a reasonable set of defaults.
Tags for configuration:
    xcodeproj-ignore-as-target: Add this to a rule declaration so that this rule will not generates a scheme for this target


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="xcodeproj-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="xcodeproj-additional_bazel_build_options"></a>additional_bazel_build_options |  -   | List of strings | optional | [] |
| <a id="xcodeproj-additional_files"></a>additional_files |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="xcodeproj-additional_lldb_settings"></a>additional_lldb_settings |  Additional LLDB settings to be added in each target's .lldbinit configuration file.   | List of strings | optional | [] |
| <a id="xcodeproj-additional_post_actions"></a>additional_post_actions |  Configure a list of post-actions for build/run/test in each scheme generated.  For each entry the key is one of build/test/run and value is a list of scripts. And it will not surface any error or output through build log.   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> List of strings</a> | optional | {} |
| <a id="xcodeproj-additional_pre_actions"></a>additional_pre_actions |  Configure a list of pre-actions for build/run/test in each scheme generated.  For each entry the key is one of build/test/run and value is a list of scripts. And it will not surface any error or output through build log.   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> List of strings</a> | optional | {} |
| <a id="xcodeproj-additional_prebuild_script"></a>additional_prebuild_script |  -   | String | optional | "" |
| <a id="xcodeproj-additional_scheme_infos"></a>additional_scheme_infos |  List of additional_scheme_info labels that append scheme information to the generated scheme for a build target.         Currently supports test actions, and test environment variables.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="xcodeproj-bazel_execution_log_enabled"></a>bazel_execution_log_enabled |  -   | Boolean | optional | False |
| <a id="xcodeproj-bazel_path"></a>bazel_path |  -   | String | optional | "bazel" |
| <a id="xcodeproj-bazel_profile_enabled"></a>bazel_profile_enabled |  -   | Boolean | optional | False |
| <a id="xcodeproj-build_wrapper"></a>build_wrapper |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | //tools/xcodeproj_shims:build-wrapper |
| <a id="xcodeproj-clang_stub"></a>clang_stub |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | //tools/xcodeproj_shims:clang-stub |
| <a id="xcodeproj-configs"></a>configs |  List of bazel configs present in the .bazelrc file that can be used to build targets.<br><br>        A Xcode build configuration will be created for each entry and a '--config=$CONFIGURATION' will         be appended to the underlying bazel invocation. Effectively allowing the configs in the .bazelrc file         to control how Xcode builds each build configuration.<br><br>        If not present the 'Debug' and 'Release' Xcode build configurations will be created by default without         appending any additional bazel invocation flags.   | List of strings | optional | [] |
| <a id="xcodeproj-deps"></a>deps |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |
| <a id="xcodeproj-generate_schemes_for_product_types"></a>generate_schemes_for_product_types |  Generate schemes only for the specified product types if this list is not empty. Product types must be valid apple product types, e.g. application, bundle.unit-test, framework. For a full list, see under keys of <code>PRODUCT_TYPE_UTI</code> under https://www.rubydoc.info/github/CocoaPods/Xcodeproj/Xcodeproj/Constants   | List of strings | optional | [] |
| <a id="xcodeproj-include_transitive_targets"></a>include_transitive_targets |  -   | Boolean | optional | False |
| <a id="xcodeproj-index_import"></a>index_import |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @build_bazel_rules_swift_index_import//:index_import |
| <a id="xcodeproj-infoplist_stub"></a>infoplist_stub |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | //rules/test_host_app:Info.plist |
| <a id="xcodeproj-installer"></a>installer |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | //tools/xcodeproj_shims:installer |
| <a id="xcodeproj-ld_stub"></a>ld_stub |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | //tools/xcodeproj_shims:ld-stub |
| <a id="xcodeproj-output_path"></a>output_path |  The output path to use when generating the xcode project.         Must be a relative path beneath the package where the xcodeproj rule is defined   | String | optional | "" |
| <a id="xcodeproj-output_processor"></a>output_processor |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | //tools/xcodeproj_shims:output-processor.rb |
| <a id="xcodeproj-print_json_leaf_nodes"></a>print_json_leaf_nodes |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | //tools/xcodeproj_shims:print_json_leaf_nodes |
| <a id="xcodeproj-project_attributes_overrides"></a>project_attributes_overrides |  Overrides for attributes that can be set at the project base level.   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a> | optional | {} |
| <a id="xcodeproj-project_name"></a>project_name |  -   | String | optional | "" |
| <a id="xcodeproj-provide_build_settings_from_target_for_pre_post_actions"></a>provide_build_settings_from_target_for_pre_post_actions |  -   | Boolean | optional | False |
| <a id="xcodeproj-scheme_existing_envvar_overrides"></a>scheme_existing_envvar_overrides |  -   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a> | optional | {} |
| <a id="xcodeproj-swiftc_stub"></a>swiftc_stub |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | //tools/xcodeproj_shims:swiftc-stub |


<a id="#xcodeproj_lldbinit"></a>

## xcodeproj_lldbinit

<pre>
xcodeproj_lldbinit(<a href="#xcodeproj_lldbinit-name">name</a>, <a href="#xcodeproj_lldbinit-out">out</a>, <a href="#xcodeproj_lldbinit-project">project</a>, <a href="#xcodeproj_lldbinit-runscript">runscript</a>, <a href="#xcodeproj_lldbinit-target_name">target_name</a>)
</pre>

Internal testing rule relying on assumptions about the xcodeproj rule above

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="xcodeproj_lldbinit-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="xcodeproj_lldbinit-out"></a>out |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
| <a id="xcodeproj_lldbinit-project"></a>project |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
| <a id="xcodeproj_lldbinit-runscript"></a>runscript |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @build_bazel_rules_ios//tools/xcodeproj_shims:lldb-settings |
| <a id="xcodeproj_lldbinit-target_name"></a>target_name |  -   | String | optional | "" |


