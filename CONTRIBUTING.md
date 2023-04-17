# Contributing

## Creating releases

If you are a maintainer of the repository and would like to tag a new release, follow these steps:

- Send a heads-up in the Slack ([#rules_ios](https://bazelbuild.slack.com/archives/C04UA35PAMR)) channel or post an issue with plan to tag a new release
- Head over to [Actions](https://github.com/bazel-ios/rules_ios/actions)
- Find the `Create release` action
- Click on `Trigger workflow`
- Type in a version number, follow SemVer whenever possible.
- After a few minutes the release should show up in the [Releases](https://github.com/bazel-ios/rules_ios/releases) page.

## Bazel 6 & LTS Support

### 5.x.x LTS Support on HEAD

LTS is a concept in [Bazel for versions](https://blog.bazel.build/2020/11/10/long-term-support-release.html)
and we currently support 5.x.x only for a brief time. _The rough ETA for
removing Bazel 5.x.x LTS support is end of Q2 2023 and if it's an issue we can
correct course sooner._

Because `rules_ios` should be loosely coupled to a given Bazel version, we can
often handle several Bazel versions concurrently on `HEAD` without significant
change and without having to have CI and review for LTS branches. Because we
want to keep running on `HEAD`, LTS support is added with branches where
necessary.  _The idea is paralleled to other to large scale migrations or python
code which supported 2.x.x and 3.x.x concurrently_.

We have a Bazel 5.x.x CI job which is the source of truth for vetting this.

### rules_apple: What's up with rules_ios_1.0

For `rules_apple` we attempt to achieve multi versions and smoothing over
maintainer velocity issues on a patched tag. For instance we may back-ported
some features to our tag like [framework_import_support](https://github.com/bazel-ios/rules_apple/commit/78476e542160be2c32d467ef856ccc2e9152f187)

### Maintainer concerns and rules_apple compatability

We may shim APIs, back port patches from `rules_apple` to add features and
smooth over integration. The unstable tag `rules_ios_1.0` has it all. If you're
just bumping `rules_apple` for Bazel 6.0 you shouldn't need to worry about the
LTS support if it passes CI. The burden to be an outlier should fall on the
outliers here - if you've got an issue we can look into it together.
