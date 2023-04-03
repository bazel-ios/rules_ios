import UIKit
import SwiftUI

#if APPCLIP
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = AppClipViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
#else
#error("This file should only be compiled for App Clip targets.")
#endif
