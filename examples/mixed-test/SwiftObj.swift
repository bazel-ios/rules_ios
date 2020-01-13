//
//  mixed_test.swift
//  mixed-test
//
//  Created by Oscar Bonilla on 7/23/18.
//  Copyright © 2018 Oscar Bonilla. All rights reserved.
//

public class SwiftObj : NSObject {

    @objc public var someProperty: NSString = "Some Initializer Val"

    override init() {}

    @objc public func someFunction(someArg:AnyObject) -> String {
        let returnVal = "You sent me \(someArg)"
        return returnVal
    }

    func someOtherFunction() {
        let objcObject: ObjcObject = ObjcObject()
        objcObject.someProperty = "Hello World"
        print(objcObject.someProperty!)
        objcObject.someMethod()
    }

}
