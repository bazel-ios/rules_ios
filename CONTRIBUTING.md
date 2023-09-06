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

The supported release for `rules_ios` is currently Bazel 6 and we'll strive to maintain support for it alongside Bazel 7.

### Maintainer concerns and rules_apple compatability

We may shim APIs, back port patches from `rules_apple` to add features and
smooth over integration.
