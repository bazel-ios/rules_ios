import InputMask
import SnapKit

/* Declaring this extension used to make the framework build fail with the error:
 * ...MixedSourceFramework-Swift.h:184:9: fatal error: module 'SwiftLibrary' not found
 * @import SwiftLibrary;
 * ~~~~~~~^~~~~~~~~~~~
 * 1 error generated.
 *
 * Find more information in https://github.com/bazel-ios/rules_ios/issues/55
 */
public extension MaskedTextInputListener {
    static var inputMaskClass: String { String(reflecting: MaskedTextInputListener.self) }
}

public let snapKitClass = String(reflecting: Constraint.self)
