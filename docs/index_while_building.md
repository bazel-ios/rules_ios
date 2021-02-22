# Index while building in Bazel


This document summarizes the status of index while building in Bazel and the
plan to implement it in different way.



## Project plan


Milestones:

## M1 Determine direction forward with prototypes
1. Consider possibilities of improving performance of "Index while building"
There are a couple avenues here:

1a. A solution that works with remote caching

1b. A solution that only runs locally. This is the status quo of objc right
now: it doesn't work with remote caching

2. Disable "Index while building" and correspondingly index-import
Need to consider the user facing impact  MDX-3735


## M2 If changing how index while building works

1. Upstream necessary code into rules_swift



