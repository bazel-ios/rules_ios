<!-- Generated with Stardoc: http://skydoc.bazel.build -->

This file contains rules to build framework binaries from your podfile or cartfile

<a id="build_carthage_frameworks"></a>

## build_carthage_frameworks

<pre>
build_carthage_frameworks(<a href="#build_carthage_frameworks-name">name</a>, <a href="#build_carthage_frameworks-carthage_version">carthage_version</a>, <a href="#build_carthage_frameworks-git_repository_url">git_repository_url</a>, <a href="#build_carthage_frameworks-directory">directory</a>, <a href="#build_carthage_frameworks-files">files</a>, <a href="#build_carthage_frameworks-cmd">cmd</a>,
                          <a href="#build_carthage_frameworks-timeout">timeout</a>, <a href="#build_carthage_frameworks-verbose">verbose</a>)
</pre>

    Builds the frameworks for the libraries specified in a Cartfile

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="build_carthage_frameworks-name"></a>name |  the rule name   |  none |
| <a id="build_carthage_frameworks-carthage_version"></a>carthage_version |  the carthage version to use   |  none |
| <a id="build_carthage_frameworks-git_repository_url"></a>git_repository_url |  the carthage repository to use   |  <code>"https://github.com/Carthage/Carthage.git"</code> |
| <a id="build_carthage_frameworks-directory"></a>directory |  the path to the directory containing the carthage setup   |  <code>""</code> |
| <a id="build_carthage_frameworks-files"></a>files |  the files required for carthage to run   |  <code>["Cartfile"]</code> |
| <a id="build_carthage_frameworks-cmd"></a>cmd |  the command to run and install carthage   |  <code>"\n        git clone --branch %s --depth 1 %s carthage_repo\n        swift run --package-path carthage_repo carthage bootstrap --no-use-binaries --platform iOS\n        "</code> |
| <a id="build_carthage_frameworks-timeout"></a>timeout |  Timeout in seconds for prebuilding carthage frameworks   |  <code>1200</code> |
| <a id="build_carthage_frameworks-verbose"></a>verbose |  if true, it will show the output of running carthage in the command line   |  <code>False</code> |


<a id="build_cocoapods_frameworks"></a>

## build_cocoapods_frameworks

<pre>
build_cocoapods_frameworks(<a href="#build_cocoapods_frameworks-name">name</a>, <a href="#build_cocoapods_frameworks-directory">directory</a>, <a href="#build_cocoapods_frameworks-files">files</a>, <a href="#build_cocoapods_frameworks-cmd">cmd</a>, <a href="#build_cocoapods_frameworks-timeout">timeout</a>, <a href="#build_cocoapods_frameworks-verbose">verbose</a>)
</pre>

    Builds the frameworks for the pods specified in a Podfile that are using the [cocoapods-binary plugin](https://github.com/leavez/cocoapods-binary)

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="build_cocoapods_frameworks-name"></a>name |  the rule name   |  none |
| <a id="build_cocoapods_frameworks-directory"></a>directory |  the path to the directory containing the cocoapods setup   |  <code>""</code> |
| <a id="build_cocoapods_frameworks-files"></a>files |  the files required for cocoapods to run   |  <code>["Podfile", "Podfile.lock", "Gemfile", "Gemfile.lock"]</code> |
| <a id="build_cocoapods_frameworks-cmd"></a>cmd |  the command to install and run cocoapods   |  <code>"\n        bundle install\n        bundle exec pod install\n        "</code> |
| <a id="build_cocoapods_frameworks-timeout"></a>timeout |  Timeout in seconds for prebuilding cocoapods   |  <code>1200</code> |
| <a id="build_cocoapods_frameworks-verbose"></a>verbose |  if true, it will show the output of running cocoapods in the command line   |  <code>False</code> |


