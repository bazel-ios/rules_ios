//
//  DeviceAttestationService.swift
//  MLSecurity
//
//  Created by Bruno Famiglietti on 5/20/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import DeviceCheck

@objc public class DeviceAttestationService : NSObject {
    
    static let timeout = DispatchTimeInterval.seconds(2)
 
    @objc public static func warmup(){
        DeviceAttestationService().generateToken(withHandler: { _,_  in })
    }
    
    @objc public func generateToken(withHandler handler : @escaping (DeviceToken?,_ error: String?) -> (Void)){
        AttestationEventTracker.shared().trackStartEvent()
        if #available(iOS 11.0, *) {
            let currentDevice = getDevice()
            if currentDevice.isSupported {
                let lock = DispatchSemaphore(value: 1)
                var shouldRunHandler = true
                DispatchQueue.global().asyncAfter(deadline: .now() + DeviceAttestationService.timeout) {
                    lock.wait()
                    defer { lock.signal() }
                    if shouldRunHandler {
                        shouldRunHandler = false
                        self.handleError(.attestation_timeout, withCompleter: handler)
                    }
                }
                currentDevice.generateToken(completionHandler: { (data, error) in
                    lock.wait()
                    defer { lock.signal() }
                    if shouldRunHandler {
                        shouldRunHandler = false
                        if let tokenData = data {
                            AttestationEventTracker.shared().trackSignatureCreatedEvent()
                            let deviceToken = DeviceToken(withValue: tokenData.base64EncodedString())
                            handler(deviceToken, nil)
                        } else {
                            self.handleError(.attestation_error, withCompleter: handler)
                        }
                    }
                })
            } else {
                self.handleError(.attestation_not_supported_by_device, withCompleter: handler)
            }
        } else {
            self.handleError(.attestation_not_supported_by_version, withCompleter: handler)
        }
    }
    
    private func handleError(_ error: AttestationError, withCompleter completer: @escaping (DeviceToken?,_ error: String?) -> (Void)) {
        completer(nil, error.raw())
        AttestationEventTracker.shared().trackError(reason: error.raw())
    }
    
    @available(iOS 11.0, *)
    func getDevice() -> DCDevice {
        return DCDevice.current
    }
}

