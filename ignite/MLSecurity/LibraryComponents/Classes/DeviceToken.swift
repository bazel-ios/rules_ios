//
//  DeviceToken.swift
//  MLSecurity
//
//  Created by Bruno Famiglietti on 5/20/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

public class DeviceToken : NSObject, Decodable {
    
    @objc public let value: String?
    
    @objc public init(withValue value: String?) {
        self.value = value
    }
}
