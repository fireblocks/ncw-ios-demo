//
//  AmountToSendViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 21/06/2023.
//

import UIKit

class AmountToSendViewController: UIViewController {
    
//MARK: - PROPERTIES
    @IBOutlet weak var assetView: UIView!
    @IBOutlet weak var maxButton: UIButton!{
        didSet{
            maxButton.layer.cornerRadius = 16
        }
    }
    @IBOutlet weak var amountInput: UILabel!
    @IBOutlet weak var amountPrice: UILabel!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet var numberPadKeys: [UIButton]!
    @IBOutlet weak var continueButton: AppActionBotton!
    @IBOutlet weak var receiveButton: AppActionBotton!

    var viewModel = AmountToSendViewModel()
    
    
//MARK: - LIFECYCLE Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        
        configView()
    }
    
    private func configView(){
        errorMessage.alpha = 0
        errorMessage.text = " "
        amountInput.text = "0 \(viewModel.getAsset().symbol)"
        
//        for key in numberPadKeys {
//            key.layer.cornerRadius = 16
//        }
        
        configAssetView()
        configButtons()
    }
    
    private func configAssetView(){
        let cellNib = UINib(nibName: "AssetViewCell", bundle: nil)
        let assetCellView = cellNib.instantiate(withOwner: nil, options: nil).first as! AssetViewCell
        assetCellView.frame = assetView.bounds
        assetCellView.translatesAutoresizingMaskIntoConstraints = false
        assetCellView.configTransparentCellWith(asset: viewModel.getAsset())
        assetView.addSubview(assetCellView)
        let horizontalConstraint = assetCellView.centerXAnchor.constraint(equalTo: assetView.centerXAnchor)
        let verticalConstraint = assetCellView.centerYAnchor.constraint(equalTo: assetView.centerYAnchor)
        let widthConstraint = assetCellView.widthAnchor.constraint(equalTo: assetView.widthAnchor)
        let heightConstraint = assetCellView.heightAnchor.constraint(equalTo: assetView.heightAnchor)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        assetCellView.contentView.backgroundColor = .clear
    }
    
    private func configButtons(){
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(handleCloseTap))]
        self.navigationItem.title = "Amount"

        continueButton.config(title: "Send", image: AssetsIcons.send.getIcon(), style: .Primary)
        continueButton.isEnabled = false
        receiveButton.config(title: "Receive", image: AssetsIcons.receive.getIcon(), style: .Secondary)
        receiveButton.isEnabled = true

    }
    
    @objc func handleCloseTap() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func maxButtonTapped(_ sender: UIButton) {
        viewModel.setMaxAmount()
    }
    
    @IBAction func numberPadKeyTapped(_ sender: UIButton) {
        let tag = sender.tag
        viewModel.addNumber(number: tag)
    }
    
    @IBAction func numberPadDoteTapped(_ sender: UIButton) {
        viewModel.addDote()
    }
    
    @IBAction func numberPadEraseTapped(_ sender: UIButton) {
        viewModel.eraseNumber()
    }
    
    
    @IBAction func continueButtonTapped(_ sender: AppActionBotton) {
        navigateToAddReceiverScreen()
    }
    
    @IBAction func receiveButtonTapped(_ sender: AppActionBotton) {
        navigateToReceiverScreen()
    }
    
    private func navigateToAddReceiverScreen(){
        let vc = SendToViewController(nibName: "SendToViewController", bundle: nil)
        vc.viewModel.transaction = viewModel.createTransaction()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToReceiverScreen(){
        let vc = ReceiveViewController(nibName: "ReceiveViewController", bundle: nil)
        vc.viewModel.asset = viewModel.asset
        vc.viewModel.asset.isExpanded = false
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

//MARK: - AmountToSendViewModelDelegate
extension AmountToSendViewController: AmountToSendViewModelDelegate {
    
    @MainActor
    func amountAndSumChanged(amount: String, price: String) {
//        UIView.animate(withDuration: 0.3) {
            self.amountInput.text = amount
            self.amountPrice.text = price
//        }
    }
    
    @MainActor
    func isAmountInputValid(isValid: Bool, errorMessage: String?, amount: Double) {
        UIView.animate(withDuration: 0.3) {
            self.continueButton.isEnabled = isValid && amount != 0
            self.errorMessage.alpha = isValid ? 0 : 1
            self.errorMessage.text = errorMessage != nil ? errorMessage! : " "
        }
    }
}
