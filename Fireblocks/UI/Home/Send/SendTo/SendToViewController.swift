//
//  SendToViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 25/06/2023.
//

import UIKit

class SendToViewController: UIViewController {
    
//MARK: - PROPERTIES
    @IBOutlet weak var assetIcon: UIImageView!
    @IBOutlet weak var amountToSend: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var textFieldBackground: UIView!
    @IBOutlet weak var scanQRCodeButton: UIImageView!
    @IBOutlet weak var eraseButton: UIImageView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var continueButton: AppActionBotton!
    
    let viewModel = SendToViewModel()
    
//MARK: - LIFECYCLE Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        addressTextField.delegate = self
        configButtons()
        configView()
    }
//MARK: - FUNCTIONS
    @IBAction func continueTapped(_ sender: AppActionBotton) {
        navigateToFeeRatePage()
    }
    
    private func configButtons(){
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(handleCloseTap))]

        let eraseTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleEraseTap(_:)))
        eraseButton.isUserInteractionEnabled = true
        eraseButton.addGestureRecognizer(eraseTapGesture)
        eraseButton.isHidden = true
        
        let scanQRCodeTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleScanQRCodeTap(_:)))
        scanQRCodeButton.isUserInteractionEnabled = true
        scanQRCodeButton.addGestureRecognizer(scanQRCodeTapGesture)
        
        continueButton.config(title: "Continue", style: .Primary)
        continueButton.isEnabled = false
    }
    
    private func configView(){
        self.navigationItem.title = "Receiving Address"
        addressTextField.tintColor = AssetsColors.white.getColor()
        textFieldBackground.layer.cornerRadius = 16
        textFieldBackground.addBorder(color: AssetsColors.gray2.getColor(), width: 1)
        
        assetIcon.image = viewModel.getAsset()?.image ?? AssetsIcons.PlaceholderIcon.getIcon()
        amountToSend.text = viewModel.getAmountToSendAsString()
        price.text = viewModel.getPriceAsString()
    }
    
    @objc private func handleCloseTap() {
        navigationController?.popToRootViewController(animated: true)
    }
    @objc private func handleEraseTap(_ gesture: UITapGestureRecognizer) {
        addressTextField.text = ""
        viewModel.setAddress(address: addressTextField.text)
    }
    
    @objc private func handleScanQRCodeTap(_ gesture: UITapGestureRecognizer) {
        let vc = QRCodeScannerViewController(delegate: self)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToFeeRatePage(){
        if let transaction = viewModel.getTransaction() {
            let vc = FeeRateViewController(nibName: "FeeRateViewController", bundle: nil)
            vc.viewModel.transaction = transaction
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//MARK: - UITextFieldDelegate
extension SendToViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        viewModel.setAddress(address: addressTextField.text)
    }
    
    func textFieldShouldReturn(_ textfield: UITextField) -> Bool {
        textfield.resignFirstResponder()
        return true
    }
}

//MARK: - QRCodeScannerViewControllerDelegate
extension SendToViewController: QRCodeScannerViewControllerDelegate {
    func gotAddress(address: String) {
        DispatchQueue.main.async {
            self.addressTextField.text = address
            self.viewModel.setAddress(address: address)
        }
    }
}

//MARK: - SendToViewModelDelegate
extension SendToViewController: SendToViewModelDelegate {
    func addressIsValid(isValid: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.eraseButton.isHidden = !isValid
            self?.continueButton.isEnabled = isValid
        }
    }
}
