public struct HTTPFlags {
    
    private let igniteService: IgniteRestClient
    private let featureFlags: FeatureFlags
    
    public init( igniteService: IgniteRestClient, featureFlags: FeatureFlags) {
        self.igniteService = igniteService
        self.featureFlags = featureFlags
    }
    
    public func requestFlags() {
        igniteService.successBlock =  { features in
            let flags = features.map {$0.toModel()}
            self.featureFlags.putAll(flags: flags)
        }
        igniteService.startService()
    }
}
