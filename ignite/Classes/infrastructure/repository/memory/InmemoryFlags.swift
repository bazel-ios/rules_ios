public class InmemoryFlags: FeatureFlags {
    
    private var flags = [String : FeatureFlag]()
    
    public func putAll(flags: [FeatureFlag]) {
        flags.forEach { flag in
            self.flags[flag.name] = flag
        }
    }
    
    public func findBy(key: String) -> FeatureFlag? {
        return flags[key]
    }
}
