<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Header Map rules

<a id="headermap"></a>

## headermap

<pre>
load("@rules_ios//rules:hmap.bzl", "headermap")

headermap(<a href="#headermap-name">name</a>, <a href="#headermap-hdrs">hdrs</a>, <a href="#headermap-direct_hdr_providers">direct_hdr_providers</a>, <a href="#headermap-namespace">namespace</a>)
</pre>

Creates a binary headermap file from the given headers,
suitable for passing to clang.

This can be used to allow headers to be imported at a consistent path,
regardless of the package structure being used.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="headermap-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="headermap-hdrs"></a>hdrs |  The list of headers included in the headermap   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="headermap-direct_hdr_providers"></a>direct_hdr_providers |  Targets whose direct headers should be added to the list of hdrs   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="headermap-namespace"></a>namespace |  The prefix to be used for header imports   | String | optional |  `""`  |


<a id="HeaderMapInfo"></a>

## HeaderMapInfo

<pre>
load("@rules_ios//rules:hmap.bzl", "HeaderMapInfo")

HeaderMapInfo(<a href="#HeaderMapInfo-files">files</a>)
</pre>

Propagates header maps

**FIELDS**

| Name  | Description |
| :------------- | :------------- |
| <a id="HeaderMapInfo-files"></a>files |  depset with headermaps    |


<a id="hmap.make_hmap"></a>

## hmap.make_hmap

<pre>
load("@rules_ios//rules:hmap.bzl", "hmap")

hmap.make_hmap(<a href="#hmap.make_hmap-actions">actions</a>, <a href="#hmap.make_hmap-headermap_builder">headermap_builder</a>, <a href="#hmap.make_hmap-output">output</a>, <a href="#hmap.make_hmap-namespace">namespace</a>, <a href="#hmap.make_hmap-hdrs_lists">hdrs_lists</a>)
</pre>

Makes an hmap file.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="hmap.make_hmap-actions"></a>actions |  a ctx.actions struct   |  none |
| <a id="hmap.make_hmap-headermap_builder"></a>headermap_builder |  an executable pointing to @bazel_build_rules_ios//rules/hmap:hmaptool   |  none |
| <a id="hmap.make_hmap-output"></a>output |  the output file that will contain the built hmap   |  none |
| <a id="hmap.make_hmap-namespace"></a>namespace |  the prefix to be used for header imports   |  none |
| <a id="hmap.make_hmap-hdrs_lists"></a>hdrs_lists |  an array of enumerables containing headers to be added to the hmap   |  none |


