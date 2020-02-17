//
//  MLCAppBehaviourManager.swift
//  MLCommons
//
//  Created by Santiago Lazzari on 23/07/2019.
//

import UIKit

public enum MLCAppBehaviourPriority: CaseIterable {
    case high
    case low
}

public class MLCAppBehaviourManager: NSObject {
    private var behaviours: [MLCAppBehaviourPriority : [MLCAppBehaviour]] = [MLCAppBehaviourPriority.high : [], MLCAppBehaviourPriority.low : []]
    
    public func subscribe(appBehaviour: MLCAppBehaviour, with priority: MLCAppBehaviourPriority) {
        behaviours[priority]!.append(appBehaviour)
    }
}

extension MLCAppBehaviourManager {
    private func excecute(method: (MLCAppBehaviour) -> Void) {
        for priority in MLCAppBehaviourPriority.allCases {
            for behaviour in behaviours[priority] ?? [] {
                method(behaviour)
            }
        }
    }
    
    @objc public func applicationIsConfiguringModules() {
        func behaviour(appBehaviour: MLCAppBehaviour) {
            appBehaviour.applicationIsConfiguringModules()
        }
        excecute(method: behaviour)
    }
    
    @objc public func applicationDidConfigureModules() {
        func behaviour(appBehaviour: MLCAppBehaviour) {
            appBehaviour.applicationDidConfigureModules()
        }
        excecute(method: behaviour)
    }
}
