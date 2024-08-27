import A
import B
import Foundation

public class Fwk {
    public init() {
        print("Fwk")
    }

    public func doSomething() {
        let a = A()
        a.doSomething()
        let b = B()
        b.doSomething()
        print("Fwk.doSomething")
    }
}
