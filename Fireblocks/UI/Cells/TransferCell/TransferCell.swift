//
//  TransferCell.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 06/07/2023.
//

import UIKit

class TransferCell: UITableViewCell {

//MARK: - PROPERTIES
    @IBOutlet weak var cellBackground: UIView!
    @IBOutlet weak var transferTitle: UILabel!
    @IBOutlet weak var assetBlockchainNameBackground: UIView!
    @IBOutlet weak var assetBlockchainName: UILabel!
    @IBOutlet weak var statusLabelBackground: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var showDetailsButton: UIButton!
    
//MARK: - LIFECYCLE functions
    override func awakeFromNib() {
        super.awakeFromNib()
        configCellView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated) 
    }
    
//MARK: - FUNCTIONS
    func configCellView(){
        assetBlockchainNameBackground.layer.cornerRadius = assetBlockchainNameBackground.frame.height / 2
        statusLabelBackground.layer.cornerRadius = 6
        showDetailsButton.setTitle("", for: .normal)
        cellBackground.layer.cornerRadius = 16
    }
    
    func configCell(with transfer: TransferInfo){
        transferTitle.text = transfer.getTransferTitle(walletId: FireblocksManager.shared.getWalletId())
        assetBlockchainName.text = transfer.blockChainName
        statusLabel.text = transfer.status.rawValue.beautifySigningStatus()
        amount.text = "\(transfer.amount.formatFractions(fractionDigits: 6))"
        price.text = transfer.getPriceString()
        
        updateStatusLabel(with: transfer.color)
        setSelected(isSelected: false)
    }
    
    func updateStatusLabel(with color: UIColor){
        statusLabel.textColor = color
        statusLabelBackground.addBorder(color: color, width: 0.5)
    }
    
    @IBAction func openTransferDetailsTapped(_ sender: UIButton) {
        
    }
    
    func setSelected(isSelected: Bool){
        var backgroundColor: UIColor? = UIColor.clear
        var textColor = AssetsColors.white.getColor()
        var subTextColor = AssetsColors.gray4.getColor()
        
        if isSelected {
            backgroundColor = AssetsColors.primaryBlue.getColor()
            textColor = AssetsColors.lightBlue.getColor()
            subTextColor = AssetsColors.lightBlue.getColor()
        }
        
        cellBackground.backgroundColor = backgroundColor?.withAlphaComponent(0.4)
        transferTitle.textColor = textColor
        amount.textColor = textColor
        price.textColor = subTextColor
    }
}
