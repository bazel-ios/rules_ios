<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#headermap"></a>

## headermap

<pre>
headermap(<a href="#headermap-name">name</a>, <a href="#headermap-flatten_headers">flatten_headers</a>, <a href="#headermap-hdr_providers">hdr_providers</a>, <a href="#headermap-hdrs">hdrs</a>, <a href="#headermap-namespace">namespace</a>)
</pre>

Creates a binary headermap file from the given headers,
suitable for passing to clang.

This can be used to allow headers to be imported at a consistent path,
regardless of the package structure being used.
    

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| flatten_headers |  Whether headers should be importable with the namespace as a prefix   | Boolean | required |  |
| hdr_providers |  Targets that provide headers. Targets must have either an Objc or CcInfo provider.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| hdrs |  The list of headers included in the headermap   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |
| namespace |  The prefix to be used for header imports when flatten_headers is true   | String | required |  |


