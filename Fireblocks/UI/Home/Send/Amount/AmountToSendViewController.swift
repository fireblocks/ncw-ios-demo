//
//  AmountToSendViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 21/06/2023.
//

import UIKit
import SwiftUI

class AmountToSendViewController: UIViewController, SwiftUIEnvironmentBridge {
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
    
    var viewModel: AmountToSendViewModel
    
    init(asset: AssetSummary) {
        self.viewModel = AmountToSendViewModel(asset: asset)
        super.init(nibName: "AmountToSendViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = AmountToSendViewModel()
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setBottomBarBackground()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        
        configView()
    }
    
    private func configView(){
        errorMessage.isHidden = true
        amountInput.numberOfLines = 2
        if let symbol = viewModel.getAsset().asset?.symbol {
            amountInput.text = "0 \(AssetsUtils.removeTestSuffix(symbol))"
        }
        for key in numberPadKeys {
            key.layer.cornerRadius = 16
        }
        
        configAssetView()
        configButtons()
    }
    
    private func configAssetView() {
        let swiftuiView = addSwiftUIView(rootView: AnyView(AssetRow(asset: viewModel.asset)), container: assetView)
        swiftuiView.backgroundColor = AssetsColors.background.getColor()
    }
    
    private func configButtons(){
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
    
    private func navigateToAddReceiverScreen() {
        let transaction = viewModel.createTransaction()
        viewModel.coordinator?.path.append(NavigationTypes.transactionRecipient(transaction))
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
