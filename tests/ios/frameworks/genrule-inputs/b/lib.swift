import c

public struct B {
    public static func run() {
       C.run()
       guard LibC != "B" else {
           fatalError()
       }
    }
}
