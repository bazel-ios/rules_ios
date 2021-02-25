# Index While Building in Bazel

This document summarizes the status of index while building in Bazel and the
plan to improve it. "Index while building" encompasses the writing of index data
from swift and clang and the usage of that data in Xcode.
For a high level design of the feature in LLVM, check the paper [Adding Index-While-Building support to Clang](https://docs.google.com/document/d/1cH2sTpgSnJZCkZtJl1aY-rzy4uGPcrI-6RrUpdATO2Q/edit)

## Current status

At the time of writing there's prior art that adds `-index-store-path` to
`rules_swift` and `rules_ios` but enabling these code paths slows down build
time in testing.

`swift` and `clang` write index data based on the status of what resides in
index-store-path. When using a transient per-swift-library index, it writes O(
M imports * N libs) indexer data and slows down compilation significantly: to
the tune of 300% slow down and 6GB+ index data in benchmarks. `rules_swift`
likes to use per `swift_library` data in order to remote cache indexes.
`rules_ios` uses a per `apple_library` index to reduce `index-import` wallclock
time.  Adding "Index while building" to Bazel needs special consideration to
both preserve performance characteristics of the original architecture of a
global index and interoperate with Bazel's remote execution and caching.

## Index while building V2 design

Like the current implementation, index while building V2 piggy backs on the
`-index-store-path` feature in clang and swift. However, in V2 of index while
building, `swift` and `clang` compilers use a global index cache internally to
preserve performance. Finally, to integrate with remote caching, actions copy
data into `bazel-out`. In other words, Bazel actions import relevant units and
records to a tree artifact output so Bazel can write the data to caches.

### Per compilation index management

As Bazel remote caching is oriented around action outputs, the index store data
is also updated to fit into this paradigm and retaining the global cache.

A program is implemented to clone a minimal per-action subset of an index store.
The program operates at the compilation level rather than caching the entire
global index by mapping compiler outputs to unit files. The program uses the
LLVM index store library to interface with index store primitives e.g. units and
records. _[This program](https://github.com/lyft/index-import/pull/53) is
orthogonal to and may or may not end up as part of Lyft's index-import_.

### rules_swift workers

Workers are extended to use a global index internally. Then, it writes records
and units into the remote cache by copying material from the worker's global
index into `bazel-out`. This logic lives in the action binary to optimize
performance and interface per compilation records with Bazel. _note: it's also
not currently possible or gainful to express the global index store in a Bazel
action output. Multiple actions cannot specify the same indexstore directory as an output._

### clang compilation

The native rules currently don't have an specify indexstore as a clang compilation action output.
[Task 2](#Task roadmap) is to update rules_cc compilation actions to write to a global index internally and
then copy the updated units+records to an output directory to ensure remote caching will work.

### Incrementally importing remotely compiled indexes

In order to import indexes into a local, global index incrementally, a program
is invoked to "import" remotely compiled indexes based on action outputs. This
may be an aspect that runs during the Xcode build in order to pass an output
file map to index import, or an ad-hoc program picking up output maps from build
events.

By default clang and swift seem to write absolute paths into the Index. If this
is invariant continues to hold, it needs to be accounted for in Bazel. e.g.
Unless all source code and compilation resided at the same directory remotely
and locally there will likely need to be a `remap`ing of paths. The previously
mentioned importing program will be smart enough to govern this - and import
only the files that were recompiled.

### Local optimization - sans index-import

One major shortcut exists locally to remove index-import: Xcode is fixed to read
directly from Bazel's global index store. Then, instead of writing to global
index and copying to `bazel-out` for remote caching, Xcode should can read right
from Bazels' global index. A "out of band" sentenial value can noop the code
path for `bazel-out`.

In order to remove the requirement to "index-import" bazel indexes, there are
special considerations in the way that Xcode and Bazel invoke compilation and
index-while-building abilities. Specifically, the file paths that Xcode and
Bazel use to address index records must be aligned. This may be achievable by
just aligning outputs between Xcode and Bazel: for example in the build system
xcbuild ( e.g. XCBuildKit ) protocol messages, in xcconfig by means of the
`.xcspec` features, or by plugin.


## Task roadmap


## T0 - Determine direction forward with prototypes
1. Consider possibilities of improving performance of "Index while building"
There are a couple avenues here:

- solution that works with remote caching

- A solution that only runs locally. This is the status quo of objc right
now: it doesn't work with remote caching

2. Disable "Index while building" and correspondingly index-import
Need to consider the user facing impact


## T1 - Index while building V2 - first pass

1. Propose changes to `rules_swift` for compilation
2. Implement an aspect to quickly pull remotely built indexes
3. Evaluate possibilities to remove `index-import` for local execution
4. Patch `rules_ios` to pass the global index for objc/cpp

## T2 - Index while building V2 - objc support
1. determine a pattern to add index while building to objc with remote caching
