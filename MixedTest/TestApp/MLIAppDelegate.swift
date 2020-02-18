//
//  MLIAppDelegate.swift
//  MLIgnite
//
//  Created by JuanFelippo on 08/23/2019.
//  Copyright (c) 2019 Mercado Libre. All rights reserved
//

import UIKit

class MLIAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //var coordinator: MLIExampleAppCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //let navController = UINavigationController()
        //coordinator = MLIExampleAppCoordinator(navigationController: navController)
        //coordinator?.start()
        
        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        return true
    }
}

