//import MLNetworking
import Foundation

@objcMembers
public class Ignite: NSObject {
    
    private static let source = InmemoryFlags()
//    private static let igniteService = IgniteRestClient(config: networkingConfig(), manager: MLRestClientServiceManager.sharedInstance())
    private static let httpFlags = HTTPFlags(featureFlags: source)
    
//    private override init() {}
    
    public static func doInitialization() {
        self.httpFlags.requestFlags()
    }
    
    public static func isFeatureEnabled() -> IsFeatureEnabled {
           let prueba = IgnitePrueba()
           return IsFeatureEnabled(featureFlags: source)
       }
    
    public static func isFeatureAvailable() -> IsFeatureAvailable {
        return IsFeatureAvailable(featureFlags: source)
    }
    
    public static func storeDefaultsFlags() -> StoreDefaultFlags {
        return StoreDefaultFlags(featureFlags: source)
    }
}

extension Ignite {
    
//    private static func  networkingConfig() -> MLNetworkingConfiguration  {
//        let config = MLNetworkingConfiguration()
//        config.baseURLString = Constants.baseUrl
//        config.path = Constants.serviceURI
//        config.httpMethod = .GET
//        return config
//    }
}

public struct Constants {
    fileprivate static let baseUrl = "https://api.mercadopago.com"
    #if DEBUG
    fileprivate static let serviceURI = "/beta/ignite"
    #else
    fileprivate static let serviceURI = "/ignite"
    #endif
}
