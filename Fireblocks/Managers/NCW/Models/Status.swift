//
//  StatusLabel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 06/07/2023.
//

import UIKit

enum Status: String, Codable {
    case confirming = "CONFIRMING"
    case broadcasting = "BROADCASTING"
    case pendingAuthorization = "PENDING_AUTHORIZATION"
    case pendingSignature = "PENDING_SIGNATURE"
    case queued = "QUEUED"
    
    case completed = "COMPLETED"
    case submitted = "SUBMITTED"
    
    case failed = "FAILED"
    case blocked = "BLOCKED"
    case cancelled = "CANCELLED"
    case rejected = "REJECTED"
    
    case unknown = "UNKNOWN"
    
}
