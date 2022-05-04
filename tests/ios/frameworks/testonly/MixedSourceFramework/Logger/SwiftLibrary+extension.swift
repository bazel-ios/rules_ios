import SwiftLibrary

/* Declaring this extension used to make the framework build fail with the error:
* ...MixedSourceFramework-Swift.h:184:9: fatal error: module 'SwiftLibrary' not found
* @import SwiftLibrary;
* ~~~~~~~^~~~~~~~~~~~
* 1 error generated.
*
* Find more information in https://github.com/bazel-ios/rules_ios/issues/55
*/
public extension Foo {
    static var aProperty: String { "hey there!" }
}

// This extension did not trigger any error because Bar does not subclass from NSObject
extension Bar {
}
