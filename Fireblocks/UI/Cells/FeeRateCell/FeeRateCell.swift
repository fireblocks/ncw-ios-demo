//
//  FeeRateCell.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 04/07/2023.
//

import UIKit

class FeeRateCell: UITableViewCell {

    @IBOutlet weak var cellBackground: UIView!
    @IBOutlet weak var speedTitle: UILabel!
    @IBOutlet weak var feeTitle: UILabel!
    var isFeeSelected: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
    }
    
    private func configView(){
        cellBackground.layer.cornerRadius = 16
    }
    
    func configCell(with fee: Fee, assetName: String){
        speedTitle.text = fee.getFeeName()
        feeTitle.text = "~" + fee.fee + " " + assetName
        if let feeDouble = Double(fee.fee)?.formatFractions(fractionDigits: 6) {
            feeTitle.text = "~" + "\(feeDouble)" + " " + assetName
        }
        setSelected(isSelected: isFeeSelected)
    }
    
    func setSelected(isSelected: Bool){
        var backgroundColor: UIColor? = UIColor.clear
        var textColor = AssetsColors.white.getColor()
        
        if isSelected {
            backgroundColor = AssetsColors.gray2.getColor()
//            textColor = AssetsColors.lightBlue.getColor()
        }
        
        cellBackground.backgroundColor = backgroundColor?.withAlphaComponent(0.4)
        speedTitle.textColor = textColor
        feeTitle.textColor = textColor
    }
}
