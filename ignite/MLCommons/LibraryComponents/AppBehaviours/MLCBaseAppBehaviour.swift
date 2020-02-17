//
//  BaseAppBehaviour.swift
//  MLCommons
//
//  Created by Santiago Lazzari on 22/07/2019.
//

import UIKit

// Abstract class. If overriding, must override all those methods
// You want to use
@objc open class MLCBaseAppBehaviour: NSObject {
    
    var state: MLCAppState
    
    init(with state: MLCAppState) {
        self.state = state
    }
}

extension MLCBaseAppBehaviour: MLCAppBehaviour {
    
    @objc public func applicationIsConfiguringModules() {
        // Override
    }
    
    @objc public func applicationDidConfigureModules() {
        // Overrider
    }
}
