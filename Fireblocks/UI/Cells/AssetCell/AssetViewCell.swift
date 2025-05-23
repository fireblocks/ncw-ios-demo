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
    }
    
    func configCellWith(asset: AssetSummary, section: Int) {
        sendButton.tag = section
        receiveButton.tag = section
        
        configCellWith(asset: asset)
    }
    
    func configTransparentCellWith(asset: AssetSummary) {
        assetContainerView.backgroundColor = .clear
        buttonsContainerView.backgroundColor = .clear
        
        configCellWith(asset: asset)
    }
    

    func configCellWith(asset: AssetSummary) {
        configAssetView(asset: asset)

        #if EW
        if let assetId = asset.asset?.id, let total = asset.balance?.total, let price = Double(total) {
            assetValue.text = CryptoCurrencyManager.shared.getTotalPrice(assetId: assetId, networkProtocol: asset.asset?.networkProtocol, amount: price)
        }
        #else
        if let rate = asset.asset?.rate,let total = asset.balance?.total, let price = Double(total) {
            assetValue.text = "$\((price * rate).formatFractions(fractionDigits: 2))"
        }
        #endif
        if let balance = asset.balance?.total?.toDouble?.formatFractions() {
            assetTokenAmount.text = "\(balance)"
        }
        
        if asset.isExpanded {
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



}
