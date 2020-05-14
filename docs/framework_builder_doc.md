<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#build_carthage_frameworks"></a>

## build_carthage_frameworks

<pre>
build_carthage_frameworks(<a href="#build_carthage_frameworks-name">name</a>, <a href="#build_carthage_frameworks-directory">directory</a>, <a href="#build_carthage_frameworks-files">files</a>, <a href="#build_carthage_frameworks-cmd">cmd</a>, <a href="#build_carthage_frameworks-quiet">quiet</a>)
</pre>

Builds the frameworks for the libraries specified in a Cartfile

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  the rule name   |  none |
| directory |  the path to the directory containing the carthage setup   |  <code>""</code> |
| files |  the files required for carthage to succeed   |  <code>["Cartfile"]</code> |
| cmd |  the command to run carthage   |  <code>"carthage bootstrap --no-use-binaries --platform iOS"</code> |
| quiet |  if true, it will show the output of running carthage in the command line   |  <code>True</code> |


<a name="#build_cocoapods_frameworks"></a>

## build_cocoapods_frameworks

<pre>
build_cocoapods_frameworks(<a href="#build_cocoapods_frameworks-name">name</a>, <a href="#build_cocoapods_frameworks-directory">directory</a>, <a href="#build_cocoapods_frameworks-files">files</a>, <a href="#build_cocoapods_frameworks-cmd">cmd</a>, <a href="#build_cocoapods_frameworks-quiet">quiet</a>)
</pre>

Builds the frameworks for the pods specified in a Podfile that are using the [cocoapods-binary plugin](https://github.com/leavez/cocoapods-binary)

**PARAMETERS**


| Name  | Description | Default Value |
| :-------------: | :-------------: | :-------------: |
| name |  the rule name   |  none |
| directory |  the path to the directory containing the cocoapods setup   |  <code>""</code> |
| files |  the files required for cocoapods to succeed   |  <code>["Podfile", "Gemfile"]</code> |
| cmd |  the command to run cocoapods   |  <code>"bundle install; bundle exec pod install"</code> |
| quiet |  if true, it will show the output of running cocoapods in the command line   |  <code>True</code> |


