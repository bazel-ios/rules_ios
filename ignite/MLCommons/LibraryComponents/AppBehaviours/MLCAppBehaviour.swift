//
//  AppBehaviour.swift
//  MLCommons
//
//  Created by Santiago Lazzari on 22/07/2019.
//

import UIKit

@objc public protocol MLCAppBehaviour {
    /**
     Life cycle of an application
     */
    @objc func applicationIsConfiguringModules()
    @objc func applicationDidConfigureModules()
    
}
