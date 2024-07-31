//
//  AssetViewCell.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 14/06/2023.
//

import UIKit

class AssetViewCell: AddAssetViewCell {

//MARK: - PROPERTIES
    @IBOutlet weak var assetTokenAmount: UILabel!
    @IBOutlet weak var assetValue: UILabel!
    
    
//MARK: - LIFECYCLE Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        configCellView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        assetValue.text = "$0"
        assetTokenAmount.text = "0"
    }
    
//MARK: - FUNCTIONS
    override func configCellView(){
        imageBackground.layer.cornerRadius = 9
        assetBlockchainBadgeBackground.layer.cornerRadius = assetBlockchainBadgeBackground.frame.height / 2
    }
    
    func configCellWith(asset: Asset, isBlockchainHidden: Bool = false) {
        configAssetView(asset: asset, isBlockchainHidden: isBlockchainHidden)

        if let price = asset.price {
            assetValue.text = "$\(price.formatFractions(fractionDigits: 2))"
        }
        if let balance = asset.balance {
            assetTokenAmount.text = "\(balance)"
        }

    }
    
}
