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
    @IBOutlet weak var myAddressLabel: UILabel!
    @IBOutlet weak var myAddressContainer: UIView!

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(TransferCell.nib, forCellReuseIdentifier: TransferCell.nibName)
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

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
    
    @IBAction func myAddressTapped(_ sender: AppActionBotton) {
        UIView.animate(withDuration: 0.3) {
            self.myAddressContainer.backgroundColor = AssetsColors.primaryBlue.getColor()
        } completion: { completion in
            UIView.animate(withDuration: 0.3) {
                self.myAddressContainer.backgroundColor = AssetsColors.gray1.getColor().withAlphaComponent(0.4)
            }
        }

        if let address = viewModel.getAsset()?.address {
            self.gotAddress(address: address)
        }
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
        myAddressLabel.text = viewModel.getAsset()?.address
        myAddressContainer.layer.cornerRadius = 16
        myAddressContainer.layer.masksToBounds = true
        myAddressContainer.backgroundColor = AssetsColors.gray1.getColor().withAlphaComponent(0.4)
    }
    
    @objc private func handleCloseTap() {
        navigationController?.popToRootViewController(animated: true)
    }
    @objc private func handleEraseTap(_ gesture: UITapGestureRecognizer) {
        addressTextField.text = ""
        viewModel.setAddress(address: addressTextField.text)
    }
    
    @objc private func handleScanQRCodeTap(_ gesture: UITapGestureRecognizer) {
        let vc = QRCodeScannerViewController(nibName: "QRCodeScannerViewController", bundle: nil)
        vc.delegate = self
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
    
    func refreshData() {
        self.tableView.reloadData()
    }
}

extension SendToViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.transfers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TransferCell {
            UIView.animate(withDuration: 0.3, animations: {
                cell.setSelected(isSelected: true)
            },completion: { finished in
                UIView.animate(withDuration: 0.3) {
                    cell.setSelected(isSelected: false)
                }
                self.gotAddress(address: self.viewModel.getTransferFor(index: indexPath.row).getReceiverAddress(walletId: FireblocksManager.shared.getWalletId()))

            })
        }


    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransferCell.nibName, for: indexPath) as? TransferCell  else {
            return UITableViewCell()
        }
        
        let transfer = viewModel.getTransferFor(index: indexPath.row)
        cell.configCell(with: transfer, isExpanded: true)

        return cell
    

    }
    
    
}
