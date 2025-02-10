<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="default_test_factory.make_named_split"></a>

## default_test_factory.make_named_split

<pre>
load("@rules_ios//rules:test.bzl", "default_test_factory")

default_test_factory.make_named_split(<a href="#default_test_factory.make_named_split-name">name</a>, <a href="#default_test_factory.make_named_split-split_kwargs">split_kwargs</a>, <a href="#default_test_factory.make_named_split-in_split">in_split</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="default_test_factory.make_named_split-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="default_test_factory.make_named_split-split_kwargs"></a>split_kwargs |  <p align="center"> - </p>   |  none |
| <a id="default_test_factory.make_named_split-in_split"></a>in_split |  <p align="center"> - </p>   |  none |


<a id="default_test_factory.make_runner_split"></a>

## default_test_factory.make_runner_split

<pre>
load("@rules_ios//rules:test.bzl", "default_test_factory")

default_test_factory.make_runner_split(<a href="#default_test_factory.make_runner_split-name">name</a>, <a href="#default_test_factory.make_runner_split-runner">runner</a>, <a href="#default_test_factory.make_runner_split-in_split">in_split</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="default_test_factory.make_runner_split-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="default_test_factory.make_runner_split-runner"></a>runner |  <p align="center"> - </p>   |  none |
| <a id="default_test_factory.make_runner_split-in_split"></a>in_split |  <p align="center"> - </p>   |  none |


<a id="default_test_factory.make_test"></a>

## default_test_factory.make_test

<pre>
load("@rules_ios//rules:test.bzl", "default_test_factory")

default_test_factory.make_test(<a href="#default_test_factory.make_test-name">name</a>, <a href="#default_test_factory.make_test-test_rule">test_rule</a>, <a href="#default_test_factory.make_test-kwargs">kwargs</a>)
</pre>

Helper to create an individual test

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="default_test_factory.make_test-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="default_test_factory.make_test-test_rule"></a>test_rule |  <p align="center"> - </p>   |  none |
| <a id="default_test_factory.make_test-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="default_test_factory.make_test_suite"></a>

## default_test_factory.make_test_suite

<pre>
load("@rules_ios//rules:test.bzl", "default_test_factory")

default_test_factory.make_test_suite(<a href="#default_test_factory.make_test_suite-factory">factory</a>, <a href="#default_test_factory.make_test_suite-name">name</a>, <a href="#default_test_factory.make_test_suite-test_rule">test_rule</a>, <a href="#default_test_factory.make_test_suite-test_kwargs">test_kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="default_test_factory.make_test_suite-factory"></a>factory |  <p align="center"> - </p>   |  none |
| <a id="default_test_factory.make_test_suite-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="default_test_factory.make_test_suite-test_rule"></a>test_rule |  <p align="center"> - </p>   |  none |
| <a id="default_test_factory.make_test_suite-test_kwargs"></a>test_kwargs |  <p align="center"> - </p>   |  none |


<a id="default_test_factory.make_test_suite_splits"></a>

## default_test_factory.make_test_suite_splits

<pre>
load("@rules_ios//rules:test.bzl", "default_test_factory")

default_test_factory.make_test_suite_splits(<a href="#default_test_factory.make_test_suite_splits-factory">factory</a>, <a href="#default_test_factory.make_test_suite_splits-name">name</a>, <a href="#default_test_factory.make_test_suite_splits-in_kwargs">in_kwargs</a>)
</pre>

Helper function to split up a test for named splits and runners splits

At the end of the day, we need to able to control how many tests / bundles
there are for sharding by class, otherwise it would recompile many times.

Finally - you can set the splits to be whatever you want.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="default_test_factory.make_test_suite_splits-factory"></a>factory |  <p align="center"> - </p>   |  none |
| <a id="default_test_factory.make_test_suite_splits-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="default_test_factory.make_test_suite_splits-in_kwargs"></a>in_kwargs |  <p align="center"> - </p>   |  none |


<a id="default_test_factory.make_tests"></a>

## default_test_factory.make_tests

<pre>
load("@rules_ios//rules:test.bzl", "default_test_factory")

default_test_factory.make_tests(<a href="#default_test_factory.make_tests-factory">factory</a>, <a href="#default_test_factory.make_tests-name">name</a>, <a href="#default_test_factory.make_tests-test_rule">test_rule</a>, <a href="#default_test_factory.make_tests-kwargs">kwargs</a>)
</pre>

Main entry point of generating tests"

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="default_test_factory.make_tests-factory"></a>factory |  <p align="center"> - </p>   |  none |
| <a id="default_test_factory.make_tests-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="default_test_factory.make_tests-test_rule"></a>test_rule |  <p align="center"> - </p>   |  none |
| <a id="default_test_factory.make_tests-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="ios_ui_test"></a>

## ios_ui_test

<pre>
load("@rules_ios//rules:test.bzl", "ios_ui_test")

ios_ui_test(<a href="#ios_ui_test-name">name</a>, <a href="#ios_ui_test-apple_library">apple_library</a>, <a href="#ios_ui_test-test_factory">test_factory</a>, <a href="#ios_ui_test-kwargs">kwargs</a>)
</pre>

Builds and packages iOS UI Tests.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="ios_ui_test-name"></a>name |  The name of the UI test.   |  none |
| <a id="ios_ui_test-apple_library"></a>apple_library |  The macro used to package sources into a library.   |  `<function apple_library from //rules:library.bzl>` |
| <a id="ios_ui_test-test_factory"></a>test_factory |  Use this to generate other variations of tests.   |  `struct(make_named_split = <function _make_named_split from //rules:test.bzl>, make_runner_split = <function _make_runner_split from //rules:test.bzl>, make_test = <function _make_test from //rules:test.bzl>, make_test_suite = <function _make_test_suite from //rules:test.bzl>, make_test_suite_splits = <function _make_test_suite_splits from //rules:test.bzl>, make_tests = <function _make_tests from //rules:test.bzl>)` |
| <a id="ios_ui_test-kwargs"></a>kwargs |  Arguments passed to the apple_library and ios_ui_test rules as appropriate.   |  none |


<a id="ios_unit_snapshot_test"></a>

## ios_unit_snapshot_test

<pre>
load("@rules_ios//rules:test.bzl", "ios_unit_snapshot_test")

ios_unit_snapshot_test(<a href="#ios_unit_snapshot_test-name">name</a>, <a href="#ios_unit_snapshot_test-apple_library">apple_library</a>, <a href="#ios_unit_snapshot_test-test_factory">test_factory</a>, <a href="#ios_unit_snapshot_test-kwargs">kwargs</a>)
</pre>

Builds and packages iOS Unit Snapshot Tests.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="ios_unit_snapshot_test-name"></a>name |  The name of the UI test.   |  none |
| <a id="ios_unit_snapshot_test-apple_library"></a>apple_library |  The macro used to package sources into a library.   |  `<function apple_library from //rules:library.bzl>` |
| <a id="ios_unit_snapshot_test-test_factory"></a>test_factory |  Use this to generate other variations of tests.   |  `struct(make_named_split = <function _make_named_split from //rules:test.bzl>, make_runner_split = <function _make_runner_split from //rules:test.bzl>, make_test = <function _make_test from //rules:test.bzl>, make_test_suite = <function _make_test_suite from //rules:test.bzl>, make_test_suite_splits = <function _make_test_suite_splits from //rules:test.bzl>, make_tests = <function _make_tests from //rules:test.bzl>)` |
| <a id="ios_unit_snapshot_test-kwargs"></a>kwargs |  Arguments passed to the apple_library and ios_unit_test rules as appropriate.   |  none |


<a id="ios_unit_test"></a>

## ios_unit_test

<pre>
load("@rules_ios//rules:test.bzl", "ios_unit_test")

ios_unit_test(<a href="#ios_unit_test-name">name</a>, <a href="#ios_unit_test-apple_library">apple_library</a>, <a href="#ios_unit_test-test_factory">test_factory</a>, <a href="#ios_unit_test-kwargs">kwargs</a>)
</pre>

Builds and packages iOS Unit Tests.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="ios_unit_test-name"></a>name |  The name of the unit test.   |  none |
| <a id="ios_unit_test-apple_library"></a>apple_library |  The macro used to package sources into a library.   |  `<function apple_library from //rules:library.bzl>` |
| <a id="ios_unit_test-test_factory"></a>test_factory |  Use this to generate other variations of tests.   |  `struct(make_named_split = <function _make_named_split from //rules:test.bzl>, make_runner_split = <function _make_runner_split from //rules:test.bzl>, make_test = <function _make_test from //rules:test.bzl>, make_test_suite = <function _make_test_suite from //rules:test.bzl>, make_test_suite_splits = <function _make_test_suite_splits from //rules:test.bzl>, make_tests = <function _make_tests from //rules:test.bzl>)` |
| <a id="ios_unit_test-kwargs"></a>kwargs |  Arguments passed to the apple_library and ios_unit_test rules as appropriate.   |  none |


