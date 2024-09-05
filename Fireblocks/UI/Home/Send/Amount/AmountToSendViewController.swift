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
    
    var viewModel = AmountToSendViewModel()
    
    
//MARK: - LIFECYCLE Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        
        configView()
    }
    
    private func configView(){
        errorMessage.isHidden = true
        amountInput.text = "0 \(viewModel.getAsset().symbol)"
        
        for key in numberPadKeys {
            key.layer.cornerRadius = 16
        }
        
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
    }
    
    private func configButtons(){
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(handleCloseTap))]
        self.navigationItem.title = "Amount"

        continueButton.config(title: "Continue", style: .Primary)
        continueButton.isEnabled = false
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
    
    private func navigateToAddReceiverScreen(){
        let vc = SendToViewController(nibName: "SendToViewController", bundle: nil)
        vc.viewModel.transaction = viewModel.createTransaction()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - AmountToSendViewModelDelegate
extension AmountToSendViewController: AmountToSendViewModelDelegate {
    
    func amountAndSumChanged(amount: String, price: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.amountInput.text = amount
            self.amountPrice.text = price
        }
    }
    
    func isAmountInputValid(isValid: Bool, errorMessage: String?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.continueButton.isEnabled = isValid
            self.errorMessage.isHidden = isValid
            self.errorMessage.text = errorMessage
        }
    }
}
