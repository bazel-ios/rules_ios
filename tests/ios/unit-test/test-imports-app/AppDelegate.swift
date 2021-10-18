//
//  AppDelegate.swift
//  Test-Imports-App-Project
//
//  Created by Maxwell Elliott on 10/18/21.
//

import Foundation
import UIKit
import TensorFlowLiteC
import TensorFlowLiteCCoreML
import MBProgressHUD
import GoogleMobileAds;

final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
                        launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let window: UIWindow = .init(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.rootViewController?.view.backgroundColor = .blue
        window.makeKeyAndVisible()
        self.window = window

        assert(EmptyClass.emptyDescription() == "", "Empty class description exists")
        assert(EmptyClass().emptyDescription() == "", "Empty instance description exists")
        GADMobileAds.sharedInstance().start()

        return true
    }
}
