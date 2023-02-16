public struct C {
    public static func run() { print("runs here") }
    public static func NATURE_OF_C() { C.run() }
}

/*
 Keep this declaration as one way to verify if indexing of static fmws is working in Xcode.

 If the indexing integration breaks then building with Bazel in Xcode will pass but
 the editor will still display errors coming from the indexing `swiftc` invocations
 for this source file. The errors will contain some or all of the messages below:

 - @objc attribute used without importing module 'Foundation'
 - Cannot find type 'NSObject' in scope
 - Only classes that inherit from NSObject can be declared @objc
 */
@objc public class CClass: NSObject{}
