public struct IsFeatureEnabled {
    
    private let featureFlags: FeatureFlags
    
    public init(featureFlags: FeatureFlags) {
        self.featureFlags = featureFlags;
    }
    
    public func doAction(name: String) -> Bool {
        return featureFlags.findBy(key: name)?.isEnabled ?? false
    }
}
