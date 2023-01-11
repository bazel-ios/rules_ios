import Foundation
import BasicXCFrameworkDynamic
import BasicXCFrameworkStatic

public func foo() {
    let foo1 = BasicXCFrameworkDynamic.Foo(num: 9000)
    foo1.bar()

    let foo2 = BasicXCFrameworkStatic.Foo(num: 9000)
    foo2.bar()
}
