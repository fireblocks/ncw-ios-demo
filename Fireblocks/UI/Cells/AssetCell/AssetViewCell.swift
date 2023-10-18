//
//  AssetViewCell.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 14/06/2023.
//

import UIKit

class AssetViewCell: UITableViewCell {

//MARK: - PROPERTIES
    @IBOutlet weak var imageBackground: UIView!
    @IBOutlet weak var assetImage: UIImageView!
    @IBOutlet weak var assetName: UILabel!
    @IBOutlet weak var assetAbbreviation: UILabel!
    @IBOutlet weak var assetBlockchainBadgeBackground: UIView!
    @IBOutlet weak var assetBlockchainBadge: UILabel!
    @IBOutlet weak var assetTokenAmount: UILabel!
    @IBOutlet weak var assetValue: UILabel!
    
    
//MARK: - LIFECYCLE Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        ConfigCellView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        assetImage.image = nil
        assetName.text = ""
        assetAbbreviation.text = ""
        assetBlockchainBadge.text = ""
        assetBlockchainBadgeBackground.isHidden = true
        assetValue.text = "$0"
        assetTokenAmount.text = "0"
    }
    
//MARK: - FUNCTIONS
    private func ConfigCellView(){
        imageBackground.layer.cornerRadius = 9
        assetBlockchainBadgeBackground.layer.cornerRadius = assetBlockchainBadgeBackground.frame.height / 2
    }
    
    func configCellWith(asset: Asset, isBlockchainHidden: Bool = false) {
        if let iconURL = asset.iconURL {
            assetImage.sd_setImage(with: URL(string: iconURL), placeholderImage: asset.image)
        } else {
            assetImage.image = asset.image
        }
        assetName.text = asset.name
        assetAbbreviation.text = asset.symbol
        assetBlockchainBadge.text = asset.blockchain
        assetBlockchainBadge.isHidden = isBlockchainHidden
        assetBlockchainBadgeBackground.isHidden = isBlockchainHidden
        if let price = asset.price {
            assetValue.text = "$\(price.formatFractions(fractionDigits: 2))"
        }
        if let balance = asset.balance {
            assetTokenAmount.text = "\(balance)"
        }

    }
}
