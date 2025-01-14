//
//  StatusLabel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 06/07/2023.
//

import UIKit

enum TransferStatusType: String, Codable {
    case Confirming = "CONFIRMING"
    case Broadcasting = "BROADCASTING"
    case PendingAuthorization = "PENDING_AUTHORIZATION"
    case PendingSignature = "PENDING_SIGNATURE"
    case Queued = "QUEUED"
    
    case Completed = "COMPLETED"
    case Submitted = "SUBMITTED"
    
    case Failed = "FAILED"
    case Blocked = "BLOCKED"
    case Cancelled = "CANCELLED"
    case Rejected = "REJECTED"
    
    case Unknown = "UNKNOWN"
    
    var color: UIColor {
        switch self {
        case .Confirming, .Broadcasting, .PendingSignature, .PendingAuthorization, .Queued:
            return (AssetsColors.inProgress.getColor())
        case .Completed, .Submitted:
            return (AssetsColors.success.getColor())
        case .Failed, .Blocked, .Cancelled, .Rejected:
            return (AssetsColors.alert.getColor())
        case .Unknown:
            return (AssetsColors.white.getColor())
        }
    }
    
    var getStatusString: String {
        switch self {
        case .PendingSignature, .PendingAuthorization:
            return self.rawValue.replacingOccurrences(of: "_", with: " ").lowercased().capitalized()
        case .Completed, .Submitted, .Confirming, .Broadcasting, .Queued, .Failed, .Blocked, .Cancelled, .Rejected, .Unknown:
            return self.rawValue.lowercased().capitalized()
        }
    }
}
