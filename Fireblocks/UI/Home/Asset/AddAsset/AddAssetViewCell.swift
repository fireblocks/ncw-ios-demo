//
//  AddAssetViewCell.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 05/10/2023.
//

import UIKit

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
        ConfigCellView()
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        assetName.text = ""
        assetAbbreviation.text = ""
        assetBlockchainBadge.text = ""
        assetBlockchainBadgeBackground.isHidden = true
    }
    
//MARK: - FUNCTIONS
    private func ConfigCellView(){
        cellBackground.layer.cornerRadius = 16
        imageBackground.layer.cornerRadius = 9
        assetBlockchainBadgeBackground.layer.cornerRadius = assetBlockchainBadgeBackground.frame.height / 2
    }
    
    func configCellWith(asset: Asset, isBlockchainHidden: Bool = false) {
        assetImage.image = asset.image
        assetName.text = asset.name
        assetAbbreviation.text = asset.symbol
        assetBlockchainBadge.text = asset.blockchain
        assetBlockchainBadge.isHidden = isBlockchainHidden
        assetBlockchainBadgeBackground.isHidden = isBlockchainHidden

    }
    
    func setSelected(isSelected: Bool){
        var backgroundColor: UIColor? = UIColor.clear
        
        if isSelected {
            backgroundColor = AssetsColors.gray2.getColor()
        }
        
        cellBackground.backgroundColor = backgroundColor
    }

}
