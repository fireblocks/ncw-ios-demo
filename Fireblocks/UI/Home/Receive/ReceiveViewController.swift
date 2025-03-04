//
//  ReceiveViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 16/07/2023.
//

import UIKit

class ReceiveViewController: UIViewController, SwiftUIEnvironmentBridge {
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var assetImage: UIImageView!
    @IBOutlet weak var assetName: UILabel!
    @IBOutlet weak var assetBlockchainNameBackground: UIView!
    @IBOutlet weak var assetBlockchainName: UILabel!
    @IBOutlet weak var qrCodeBackground: UIView!
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var addressBackground: UIView!
    @IBOutlet weak var assetAddressTitle: UILabel!
    @IBOutlet weak var assetAddress: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    
    let viewModel: ReceiveViewModel
    
    #if EW
    func setEnvironment(loadingManager: LoadingManager, coordinator: Coordinator, ewManager: EWManager) {
        viewModel.loadingManager = loadingManager
    }
    #else
    func setEnvironment(loadingManager: LoadingManager, coordinator: Coordinator) {
        viewModel.loadingManager = loadingManager
    }
    #endif

    init(asset: AssetSummary) {
        self.viewModel = ReceiveViewModel(asset: asset)
        super.init(nibName: "ReceiveViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = ReceiveViewModel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    private func configView() {
        assetBlockchainNameBackground.layer.cornerRadius = assetBlockchainNameBackground.bounds.height / 2
        qrCodeBackground.layer.cornerRadius = 16
        addressBackground.layer.cornerRadius = 16
        copyButton.setTitle("", for: .normal)
        
        if let iconURL = viewModel.asset.iconUrl {
            assetImage.sd_setImage(with: URL(string: iconURL), placeholderImage: viewModel.asset.image)
        } else {
            assetImage.image = viewModel.asset.image
        }
        assetName.text = viewModel.asset.asset?.name
        assetBlockchainName.text = viewModel.asset.asset?.blockchain
        assetAddressTitle.text = "\(viewModel.asset.asset?.symbol ?? "") address"
        assetAddress.text = viewModel.getAssetAddress()
        
        qrCodeImage.image = getQRCodeImage()
    }
        
    @IBAction func copyAddressTapped(_ sender: UIButton) {
        guard let copiedString = assetAddress.text else {
            viewModel.loadingManager?.toastMessage = "Asset not defined - Copy failed"
            return
        }
        
        UIPasteboard.general.string = copiedString
        viewModel.loadingManager?.toastMessage = "Copied"
    }
    
    func getQRCodeImage() -> UIImage {
        let qrCodeImage = QRCodeGenerator().getQRCodeUIImage(from: viewModel.getAssetAddress()) ?? UIImage()
        return qrCodeImage
    }
    
}
