# Index While Building in Bazel

This document summarizes the status of index while building in Bazel and the
plan to improve it. "Index while building" encompases the writing of index data
from swift and clang and then consumption of that inside of that data in Xcode.
For a high level design of the feature in LLVM, check the whitepaper [Adding Index-While-Building support to Clang](https://docs.google.com/document/d/1cH2sTpgSnJZCkZtJl1aY-rzy4uGPcrI-6RrUpdATO2Q/edit)

## High level summary and status

At the time of writing there's prior art that adds `-index-store-path` to
`rules_swift` and `rules_ios` but enabling these code paths slows down build
time in testing.

`swift` and `clang` write index data based on the status of what resides in
index-store-path. When using a transient per-swift-library index, it writes O(
M imports * N libs) indexer data and slows down compilation significantly: to
the tune of 300% slow down and 6GB+ index data in my testing. `rules_swift`
likes to use per `swift_library` data in order to remote cache indexes
`rules_ios` uses a per `apple_library` index to reduce `index-import` wallclock
time.  Adding "Index while building" to bazel needs special consideration to
preserve performance characteristics of the original architecture of a global
index while interoperating with remote execution and caching.

## Index while building V2

### rules_swift workers

Workers are extended to use a global index internally. Records and units into
the remote cache by copying material from the worker's global index into
`bazel-out`. This fixes

### clang compilation

The native rules don't have an extra output for indexstore. These rules are
updated to use the global index and in M3 remote caching for clang compilation
is added.


#### Incrementally importing remotely compiled indexes

In order to import indexs into Xcode incrementally, a program is invoked to
"import" remotely compiled indexes. This may be an aspect that runs during the
Xcode build in order to pass an output file map to index import, or an ad-hoc
program picking up output maps from build events.

By default clang and swift seem to write absolute paths into the Index. If this
is invariant continues to hold, it needs to be accounted for in Bazel. e.g.
Unless all source code and compilation resided at the same directory remotely
and locally there will likely need to be a `remap`ing of paths. The previously
mentioned importing program will be smart enough to govern this - and import
only the files that were recompiled.

### Local optimization - sans index-import

Initially the feature will work the same locally as it does remotely.

However, one major shortcut exists locally to remove index-import. Xcode should
read directly from Bazel's global index store. In other words, instead of
writing to the per module index, and copying to `bazel-out` for remote caching,
Xcode should pull right from that index. A "out of band" sentenial value can noop
the code path for `bazel-out`.

In order to remove the requirement to "index-import" bazel indexes, there are
special considerations in the way that Xcode and Bazel invoke compilation and
index-while-building abilities. Specifically, the file paths that Xcode and
Bazel use to address index records must be aligned. This may be achievable by
just aligning outputs between Xcode and Bazel: for example in the build system
xcbuild ( e.g. XCBuildKit ) protocol messages, in xcconfig by means of the
`.xcspec` features, or by plugin.


## Task roadmap 


## Determine direction forward with prototypes
1. Consider possibilities of improving performance of "Index while building"
There are a couple avenues here:

- solution that works with remote caching

- A solution that only runs locally. This is the status quo of objc right
now: it doesn't work with remote caching

2. Disable "Index while building" and correspondingly index-import
Need to consider the user facing impact  MDX-3735


## Land index while building V2 - first pass

1. Propose changes to `rules_swift` for compilation
2. Implement an aspect to quickly pull remotely built indexes
3. Evaluate possibilities to remove `index-import` for local execution
4. Patch `rules_ios` to pass the global index for objc/cpp

## Land index while building V2 - objc support
1. determine a pattern to add index while building to objc with remote caching
