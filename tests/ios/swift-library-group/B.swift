import A
import Foundation

public class B {
    public init() {
        print("B")
    }

    public func doSomething() {
        let a = A()
        a.doSomething()
        print("B.doSomething")
    }
}
