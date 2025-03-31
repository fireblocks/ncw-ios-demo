//
//  AddAssetViewCell.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 05/10/2023.
//

import UIKit
import SDWebImage

#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

class AddAssetViewCell: UITableViewCell {

//MARK: - PROPERTIES
    @IBOutlet weak var cellBackground: UIView!
    @IBOutlet weak var imageBackground: UIView!
    @IBOutlet weak var assetImage: UIImageView!
    @IBOutlet weak var assetName: UILabel!
    @IBOutlet weak var assetAbbreviation: UILabel!
    @IBOutlet weak var assetBlockchainBadgeBackground: UIView!
    @IBOutlet weak var assetBlockchainBadge: UILabel!
    
    
//MARK: - LIFECYCLE Functions
    override func awakeFromNib() {
        super.awakeFromNib()
        configCellView()
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        assetImage.image = nil
        assetName.text = ""
        assetAbbreviation.text = ""
        assetBlockchainBadge.text = ""
        assetBlockchainBadgeBackground.isHidden = true
    }
    
//MARK: - FUNCTIONS
    func configCellView(){
        cellBackground.layer.cornerRadius = 16
        imageBackground.layer.cornerRadius = 9
        assetBlockchainBadgeBackground.layer.cornerRadius = assetBlockchainBadgeBackground.frame.height / 2
    }
    
    func configCellWith(assetToAdd: AssetToAdd, isBlockchainHidden: Bool = false) {
        let asset = assetToAdd.asset
        configAssetView(asset: asset, isBlockchainHidden: isBlockchainHidden)
        cellBackground.backgroundColor = assetToAdd.isSelected ? AssetsColors.gray2.getColor() : .clear

    }
    
    func configAssetView(asset: AssetSummary, isBlockchainHidden: Bool = false) {
        if let iconURL = asset.iconUrl {
            assetImage.sd_setImage(with: URL(string: iconURL), placeholderImage: asset.image)
        } else {
            assetImage.image = asset.image
        }
        
        imageBackground.backgroundColor = isBackgroundTransparent(asset: asset.asset) ? .white : .clear

        guard let asset = asset.asset else { return }
        
        assetName.text = asset.name
        assetAbbreviation.text = asset.symbol
        assetBlockchainBadge.text = asset.blockchain
        assetBlockchainBadge.isHidden = isBlockchainHidden
        assetBlockchainBadgeBackground.isHidden = isBlockchainHidden
    }

    private func isBackgroundTransparent(asset: Asset?) -> Bool {
        if let symbol =  asset?.symbol, symbol.lowercased().hasPrefix("algo") { return true }
        
        return false
    }

}
