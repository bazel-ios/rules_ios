import c
import WidgetKit

public struct B {
    public static func run() { C.run() }
    public static func NATURE_OF_B() { B.run() }

    @available(iOS 14.0, *)
    public static func runExtension() -> [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            [.accessoryCircular]
        } else {
            []
        }
    }
}
