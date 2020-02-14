public struct StoreDefaultFlags {
    
    private let featureFlags: FeatureFlags
    
    public init(featureFlags: FeatureFlags) {
        self.featureFlags = featureFlags;
    }
    
    public func doAction(_ defaultFeatureFlags: [FeatureFlag]) {
        featureFlags.putAll(flags: defaultFeatureFlags)
    }
}
