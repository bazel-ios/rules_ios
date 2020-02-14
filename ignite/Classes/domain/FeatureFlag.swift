public struct FeatureFlag {

    public let name: String
    public let isEnabled: Bool
    
    public init(name: String, isEnabled: Bool) {
        self.name = name
        self.isEnabled = isEnabled
    }
}
