//
//  MpcKeyCellView.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 27/06/2023.
//

import UIKit
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

class MpcKeyCellView: UICollectionViewCell {
    
    static let identifier = "MpcKeyCellView"
    
    @IBOutlet weak var keyIdLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusBackgroundView: UIView!
    @IBOutlet weak var algorithmLabel: UILabel!
    
    func setData(mpcKey: KeyDescriptor){
        setKeyData(mpcKey)
        initStatusBackgroundView(isHidden: mpcKey.keyStatus != .READY)
    }
    
    private func setKeyData(_ mpcKey: KeyDescriptor) {
        keyIdLabel.text     = mpcKey.keyId == nil ? "-" : mpcKey.keyId!.isEmpty ? "-" : mpcKey.keyId
        statusLabel.text    = mpcKey.keyStatus?.rawValue.lowercased().capitalized() ?? ""
        algorithmLabel.text = mpcKey.algorithm?.rawValue ?? ""
    }
    
    private func initStatusBackgroundView(isHidden: Bool) {
        statusBackgroundView.isHidden           = isHidden
        statusBackgroundView.layer.borderColor  = AssetsColors.success.getColor().cgColor
        statusBackgroundView.layer.borderWidth  = 1
        statusBackgroundView.layer.cornerRadius = 8
    }
}
