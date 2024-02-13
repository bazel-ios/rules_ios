# Contributing

## Creating releases

If you are a maintainer of the repository and would like to tag a new release, follow these steps:

- Send a heads-up in the Slack ([#rules_ios](https://bazelbuild.slack.com/archives/C04UA35PAMR)) channel or post an issue with plan to tag a new release
- Head over to [Actions](https://github.com/bazel-ios/rules_ios/actions)
- Find the `Create release` action
- Click on `Trigger workflow`
- Type in a version number, follow SemVer whenever possible.
- After a few minutes the release should show up in the [Releases](https://github.com/bazel-ios/rules_ios/releases) page.

## Publishing new versions to the Bazel Central Registry

We automate publishing to the [Bazel Central Registry](https://registry.bazel.build/) with the [Publish to BCR](https://github.com/bazel-contrib/publish-to-bcr) GitHub app.

It will create a [PR like this one](https://github.com/bazelbuild/bazel-central-registry/pull/1063) whenever a new release is created. As such, there is no extra action required from the maintainers. Simply create a release and let the app publish it to the BCR.

If you need more reviews in the BCR repository you can ask in the [#bzlmod channel of the Bazel Slack](https://bazelbuild.slack.com/archives/C014RARENH0).
