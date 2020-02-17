import MLNetworking

public class IgniteRestClient: MLRestClientService {

    private let manager: MLRestClientServiceManager

    public var successBlock: (( _ response: [IgniteModel]) -> Void)?
    public var failureBlock: (( _ error: MLNetworkingOperationError) -> Void)?
    public var canceledBlock: (( _ error: MLNetworkingOperationError) -> Void)?

    public init(config: MLNetworkingConfiguration, manager: MLRestClientServiceManager) {
        self.manager = manager
        super.init()
        self.config = config
        self.authenticationMode = .userOptional
    }

    override public func parse(withMLResponse response: MLNetworkingOperationResponse,
                        withCompletionBlock completionBlock: @escaping MLServiceParseCompletionBlock) {
        do {
            let model = try JSONDecoder().decode([IgniteModel].self, from: response.responseData!)
            completionBlock(model)
        } catch {
            completionBlock(MLNetworkingOperationError.badFormatError())
        }
    }

    override public func onServiceSuccessParseFinished(_ object: Any) {

        guard let listOfModels = object as? [IgniteModel] else {
	        return
        }
        successBlock?(listOfModels)
    }

    override public func onServiceFinishWithError(_ error: MLNetworkingOperationError) {
	    failureBlock?(error)
    }

    override public func onServiceCanceled(_ error: MLNetworkingOperationError) {
	    canceledBlock?(error)
    }

    func startService() {
        manager.enqueue(self)
    }
}

@objc public class IgniteModel: NSObject, Codable {
    let id: String
    let status: Bool

    func toModel() -> FeatureFlag {
        return FeatureFlag(name: id, isEnabled: status)
    }
}

extension MLNetworkingOperationError {
    static func badFormatError() -> MLNetworkingOperationError {
        return MLNetworkingOperationError(domain: "com.mercadopago.ignite",
                                          code: -1,
                                          userInfo: [NSLocalizedDescriptionKey: "Bad format"])
    }
}
