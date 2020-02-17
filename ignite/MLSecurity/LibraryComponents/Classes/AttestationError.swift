//
//  AttestationError.swift
//  MLSecurity
//
//  Created by Bruno Famiglietti on 6/13/19.
//

import Foundation

enum AttestationError : String {
    case attestation_error
    case attestation_not_supported_by_device
    case attestation_not_supported_by_version
    case attestation_timeout
    
    func raw() -> String { return self.rawValue }
}
