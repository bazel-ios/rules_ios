//
//  AttestationEventTracker.swift
//  MLSecurity
//
//  Created by Bruno Famiglietti on 6/13/19.
//

import Foundation

@objc public class TrackerData : NSObject {
    @objc public var value: String
    @objc public var key: String
    
    @objc init(_ value: String, key: String) {
        self.value = value
        self.key = key
    }
}

@objc public protocol Tracker {
    func trackEvent(withPath: String, withData: TrackerData?)
}

class VoidTracker : Tracker {
    func trackEvent(withPath: String, withData: TrackerData?) {}
}

@objc public class AttestationEventTracker: NSObject {
    
    private static let ATTESTATION_START = "/auth/attestation/start";
    private static let SIGNATURE_CREATED = "/auth/attestation/signature/created";
    private static let SIGNATURE_FAIL = "/auth/attestation/signature/fail";
    private static let FAILURE_REASON_TAG = "reason";
    
    static var instance = AttestationEventTracker()
    
    let tracker: Tracker
    
    private init(withTracker tracker: Tracker = VoidTracker()) {
        self.tracker = tracker
    }
    
    @objc public static func initialize(withTracker tracker: Tracker) {
        instance = AttestationEventTracker(withTracker: tracker)
    }
    
    static func shared() -> AttestationEventTracker{
        return instance
    }
    
    func trackStartEvent() {
        tracker.trackEvent(withPath: AttestationEventTracker.ATTESTATION_START, withData: nil)
    }
    
    func trackSignatureCreatedEvent() {
        tracker.trackEvent(withPath: AttestationEventTracker.SIGNATURE_CREATED, withData: nil)
    }
    
    func trackError(reason: String) {
        tracker.trackEvent(withPath: AttestationEventTracker.SIGNATURE_FAIL, withData: TrackerData(reason, key: AttestationEventTracker.FAILURE_REASON_TAG))
    }
}
