import Foundation
import BasicXCFrameworkDynamic
import BasicXCFrameworkStatic

public func foo() {
    let foo1 = FooDynamic(num: 9000)
    foo1.bar()

    let foo2 = FooStatic(num: 9000)
    foo2.bar()
}
