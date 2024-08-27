import A
import B
import C
import Fwk
import Foundation
import SwiftUI

@main
struct App: App {
    var body: some Scene {
        WindowGroup {
            Text("App")
        }
    }

    func doSomething() {
        let a = A()
        a.doSomething()
        let b = B()
        b.doSomething()
        let c = C()
        c.doSomething()
        let fwk = Fwk()
        fwk.doSomething()
        print("App.doSomething")
    }
}
