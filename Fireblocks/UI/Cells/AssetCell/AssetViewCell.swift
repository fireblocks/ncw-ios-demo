//
//  AssetViewCell.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 14/06/2023.
//

import UIKit

protocol AssetViewCellDelegate: AnyObject {
    func didTapSend(index: Int)
    func didTapReceive(index: Int)
}

class AssetViewCell: AddAssetViewCell {

//MARK: - PROPERTIES
    @IBOutlet weak var assetTokenAmount: UILabel!
    @IBOutlet weak var assetValue: UILabel!
    @IBOutlet weak var assetContainerView: UIView!
    @IBOutlet weak var buttonsContainerView: UIView!
    @IBOutlet weak var buttonsContainerViewHC: NSLayoutConstraint!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var receiveButton: UIButton!
    
    weak var delegate: AssetViewCellDelegate?
    
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
        assetValue.text = "$0"
        assetTokenAmount.text = "0"
    }
    
//MARK: - FUNCTIONS
    override func configCellView(){
        imageBackground.layer.cornerRadius = 9
        assetBlockchainBadgeBackground.layer.cornerRadius = assetBlockchainBadgeBackground.frame.height / 2
    }
    
    func configCellWith(asset: Asset, section: Int, isBlockchainHidden: Bool = false) {
        sendButton.tag = section
        receiveButton.tag = section
        
        configCellWith(asset: asset, isBlockchainHidden: isBlockchainHidden)
    }
    
    func configTransparentCellWith(asset: Asset, isBlockchainHidden: Bool = false) {
        assetContainerView.backgroundColor = .clear
        buttonsContainerView.backgroundColor = .clear
        
        configCellWith(asset: asset, isBlockchainHidden: isBlockchainHidden)
    }
    

    func configCellWith(asset: Asset, isBlockchainHidden: Bool = false) {
        configAssetView(asset: asset, isBlockchainHidden: isBlockchainHidden)

        if let price = asset.price {
            assetValue.text = "$\(price.formatFractions(fractionDigits: 2))"
        }
        if let balance = asset.balance {
            assetTokenAmount.text = "\(balance)"
        }
        
        if let isExpanded = asset.isExpanded, isExpanded {
            buttonsContainerViewHC.constant = 80
        } else {
            buttonsContainerViewHC.constant = 0
        }

        self.buttonsContainerView.layoutIfNeeded()
        
    }
    
    @IBAction func didTapSend(_ sender: UIButton){
        delegate?.didTapSend(index: sender.tag)
    }
    
    @IBAction func didTapReceive(_ sender: UIButton){
        delegate?.didTapReceive(index: sender.tag)
    }

    func setSelected(isSelected: Bool){
        var backgroundColor: UIColor? = AssetsColors.gray1.getColor()
        if isSelected {
            backgroundColor = AssetsColors.primaryBlue.getColor().withAlphaComponent(0.4)
        }
        contentView.backgroundColor = backgroundColor
        contentView.backgroundColor = backgroundColor
    }


}
