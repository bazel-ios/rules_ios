public protocol FeatureFlags {
    
    func findBy(key: String) -> FeatureFlag?
    func putAll(flags: [FeatureFlag])
}
