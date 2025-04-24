//
//  SendToViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 25/06/2023.
//

import UIKit

class SendToViewController: UIViewController, SwiftUIEnvironmentBridge {
    
//MARK: - PROPERTIES
    @IBOutlet weak var assetIcon: UIImageView!
    @IBOutlet weak var amountToSend: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var textFieldBackground: UIView!
    @IBOutlet weak var scanQRCodeButton: UIImageView!
    @IBOutlet weak var eraseButton: UIImageView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var continueButton: AppActionBotton!
        
    let viewModel: SendToViewModel
    
    init(transaction: FBTransaction) {
        viewModel = SendToViewModel(transaction: transaction)
        super.init(nibName: "SendToViewController", bundle: nil)
        viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        viewModel = SendToViewModel()
        super.init(coder: aDecoder)
    }
    
    #if EW
    func setEnvironment(loadingManager: LoadingManager, coordinator: Coordinator, ewManager: EWManager) {
        viewModel.loadingManager = loadingManager
        viewModel.coordinator = coordinator
    }
    #else
    func setEnvironment(loadingManager: LoadingManager, coordinator: Coordinator) {
        viewModel.loadingManager = loadingManager
        viewModel.coordinator = coordinator
    }
    #endif

//MARK: - LIFECYCLE Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        addressTextField.delegate = self
        configButtons()
        configView()
    }
//MARK: - FUNCTIONS
    @IBAction func continueTapped(_ sender: AppActionBotton) {
        navigateToFeeRatePage()
    }
    
    private func configButtons(){
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
        addressTextField.tintColor = AssetsColors.white.getColor()
        textFieldBackground.layer.cornerRadius = 16
        textFieldBackground.addBorder(color: AssetsColors.gray2.getColor(), width: 1)
        
        let asset = viewModel.getAsset()
        let assetSymbol = asset?.asset?.symbol ?? ""
        
        AssetImageLoader.shared.loadAssetIcon(
            into: assetIcon,
            iconUrl: asset?.iconUrl,
            symbol: assetSymbol
        )
        
        amountToSend.text = viewModel.getAmountToSendAsString()
        price.text = viewModel.getPriceAsString()
    }
    
    @objc private func handleEraseTap(_ gesture: UITapGestureRecognizer) {
        addressTextField.text = ""
        viewModel.setAddress(address: addressTextField.text!)
    }
    
    @objc private func handleScanQRCodeTap(_ gesture: UITapGestureRecognizer) {
        let vc = QRCodeScannerViewController(delegate: self)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToFeeRatePage(){
        if let transaction = viewModel.getTransaction() {
            viewModel.coordinator?.path.append(NavigationTypes.selectFee(transaction))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//MARK: - UITextFieldDelegate
extension SendToViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        viewModel.setAddress(address: addressTextField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textfield: UITextField) -> Bool {
        textfield.resignFirstResponder()
        return true
    }
}

//MARK: - QRCodeScannerViewControllerDelegate
extension SendToViewController: QRCodeScannerViewControllerDelegate {
    @MainActor
    func gotAddress(address: String) {
        self.addressTextField.text = address
        self.viewModel.setAddress(address: address)
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
