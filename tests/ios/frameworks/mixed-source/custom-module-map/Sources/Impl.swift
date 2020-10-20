import CustomModuleMap.SuperSecret

public class C: A {
    private let x: SuperSecret
    public override init() {
        x = SuperSecret()
        super.init()
    }
}
