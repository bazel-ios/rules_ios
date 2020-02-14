//
//  IsFeatureAviable.swift
//  Adjust
//
//  Created by Rodrigo Pintos Costa on 1/8/20.
//

import Foundation

public struct IsFeatureAvailable {
    
    private let featureFlags: FeatureFlags
    
    public init(featureFlags: FeatureFlags) {
        self.featureFlags = featureFlags;
    }
    
    public func doAction(name: String, defaultValue: Bool) -> Bool {
        return featureFlags.findBy(key: name)?.isEnabled ?? defaultValue
    }
}
