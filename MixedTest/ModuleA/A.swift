import Foundation
import ModuleC

@objcMembers
public class A: NSObject {

	public func doValidate() -> Bool {
        return true
    }

    func methodA(){
    	let b = B()
    	b.methodB()
    	let c = C()
    	c.methodC()
    	
    }

}
