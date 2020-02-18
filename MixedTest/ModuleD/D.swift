import Foundation
import ModuleE

@objcMembers
public class D: NSObject {

	public func doValidate() -> Bool {
        return true
    }

    func methodE(){
    	let e = E()
    	e.doValidate()
    }

}