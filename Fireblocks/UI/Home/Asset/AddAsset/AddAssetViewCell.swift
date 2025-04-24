//
//  AddAssetViewCell.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 05/10/2023.
//

import UIKit
import SDWebImage
import SwiftUI

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
    }
    
//MARK: - FUNCTIONS
    func configCellView(){
        cellBackground.layer.cornerRadius = 16
        imageBackground.layer.cornerRadius = 9
    }
    
    func configCellWith(assetToAdd: AssetToAdd) {
        let asset = assetToAdd.asset
        configAssetView(asset: asset)
        cellBackground.backgroundColor = assetToAdd.isSelected ? AssetsColors.gray2.getColor() : .clear

    }
    
    func configAssetView(asset: AssetSummary) {
        let assetSymbol = asset.asset?.symbol ?? ""
        
        AssetImageLoader.shared.loadAssetIcon(
            into: assetImage,
            iconUrl: asset.iconUrl,
            symbol: assetSymbol
        )
        
        imageBackground.backgroundColor = isBackgroundTransparent(asset: asset.asset) ? .white : .clear

        guard let asset = asset.asset else { return }
        let title = AssetsUtils.getAssetTitleText(asset: asset)
        assetName.text = title
        assetAbbreviation.text = asset.name
    }

    private func isBackgroundTransparent(asset: Asset?) -> Bool {
        if let symbol =  asset?.symbol, symbol.lowercased().hasPrefix("algo") { return true }
        
        return false
    }

}
