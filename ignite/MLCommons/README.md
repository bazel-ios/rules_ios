# iOS Commons
Common components for iOS developers working on MercadoLibre's [native app](https://github.com/mercadolibre/mobile-ios)

## Status
* Master: [![CircleCI](https://circleci.com/gh/mercadolibre/mobile-ios_commons/tree/master.svg?style=svg)](https://circleci.com/gh/mercadolibre/mobile-ios_commons/tree/master)
[![codecov](https://codecov.io/gh/mercadolibre/mobile-ios_commons/branch/master/graph/badge.svg?token=aJvOhV7JqA)](https://codecov.io/gh/mercadolibre/mobile-ios_commons)
* Develop: [![CircleCI](https://circleci.com/gh/mercadolibre/mobile-ios_commons/tree/develop.svg?style=svg)](https://circleci.com/gh/mercadolibre/mobile-ios_commons/tree/develop)
[![codecov](https://codecov.io/gh/mercadolibre/mobile-ios_commons/branch/develop/graph/badge.svg?token=aJvOhV7JqA)](https://codecov.io/gh/mercadolibre/mobile-ios_commons)

## Repo Usage
We use [this branching model](http://nvie.com/posts/a-successful-git-branching-model/). That means **not cloning nor pushing to *master* branch**

Instead, branch or fork from [develop](https://github.com/mercadolibre/mobile-ios_commons/tree/develop) and when you are ready to merge your awesome feature, [create a Pull Request](https://github.com/mercadolibre/mobile-ios_commons/pulls) *with development as your base branch*.

## Installation with CocoaPods
We use [CocoaPods](http://cocoapods.org) as our dependency manager for Cocoa projects. See their [Getting Started](http://guides.cocoapods.org/using/getting-started.html) guide for more info.

If this is your first time using one of our pods, you must add our [Specs repo](https://github.com/mercadolibre/mobile-ios_specs) to your development environment.

### Setting up MELI's specs repo
You have two options for this:

1. Adding the repo to your local spec-repos dir (`~/.cocoapods/repos/`). Then you can refer to it by name. Ex:
```bash
$ pod repo add MLPods https://github.com/mercadolibre/mobile-ios_specs.git
```
2. Adding the repo to your `Podfile`:
```ruby
source 'https://github.com/mercadolibre/mobile-ios_specs.git'
```

### Podfile
Once the specs repo is successfully imported to your development environment, add this to your `Podfile`:
```ruby
pod 'MLCommons'
```

## Getting Started
We are working on our [wiki](https://github.com/mercadolibre/mobile-ios_commons/wiki). Stay tuned!

## Contributing
All PRs are welcome if they meet the following conditions:

* You branched or forked from [develop](https://github.com/mercadolibre/mobile-ios_commons/tree/develop)
* Your code is beautified with [Uncrustify](http://uncrustify.sourceforge.net/). Note there's already an [uncrustify.cfg](uncrustify.cfg) file in this project. **Protip:** Consider autoformatting with [BBUncrustifyPlugin-Xcode](https://github.com/benoitsan/BBUncrustifyPlugin-Xcode)
* The features you are adding are tested. Note that all PRs are automatically checked by [Travis](https://magnum.travis-ci.com/mercadolibre/mobile-ios_commons)

You may also [create an issue](https://github.com/mercadolibre/mobile-ios_commons/issues) for reporting bugs (with the appropriate *bug* label) or feature requests (with an *enhancement* label).

## Contact
Questions? Feedback? Contact us at [mobile IT at meli](mailto:mobile@mercadolibre.com)!
