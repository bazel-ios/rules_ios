import Foundation
//import ModuleD
import ModuleC

@objcMembers
public class A: NSObject {

	public func doValidate() -> Bool {
        return true
    }

    func methodA(){
    	let b = B()
    	b.methodB()

		//let d = D()
    	//d.doValidate()

    	let c = C()
    	c.methodC()
    	
    }

}
