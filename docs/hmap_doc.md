<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#headermap"></a>

## headermap

<pre>
headermap(<a href="#headermap-name">name</a>, <a href="#headermap-direct_hdr_providers">direct_hdr_providers</a>, <a href="#headermap-hdrs">hdrs</a>, <a href="#headermap-namespace">namespace</a>)
</pre>

Creates a binary headermap file from the given headers,
suitable for passing to clang.

This can be used to allow headers to be imported at a consistent path,
regardless of the package structure being used.
    

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| direct_hdr_providers |  Targets whose direct headers should be added to the list of hdrs   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| hdrs |  The list of headers included in the headermap   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |
| namespace |  The prefix to be used for header imports   | String | optional | "" |


<a name="#HeaderMapInfo"></a>

## HeaderMapInfo

<pre>
HeaderMapInfo(<a href="#HeaderMapInfo-files">files</a>)
</pre>

Propagates header maps

**FIELDS**


| Name  | Description |
| :-------------: | :-------------: |
| files |  depset with headermaps    |


