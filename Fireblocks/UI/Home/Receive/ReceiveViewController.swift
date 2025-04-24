//
//  ReceiveViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 16/07/2023.
//

import UIKit
import SwiftUI

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
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var qrContainer: UIView!

    let viewModel: ReceiveViewModel
    
    #if EW
    func setEnvironment(loadingManager: LoadingManager, coordinator: Coordinator, ewManager: EWManager) {
    }
    #else
    func setEnvironment(loadingManager: LoadingManager, coordinator: Coordinator) {
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setBottomBarBackground()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    private func configView() {
        qrContainer.layer.cornerRadius = 16.0
        qrContainer.layer.masksToBounds = true

        assetBlockchainNameBackground.layer.cornerRadius = assetBlockchainNameBackground.bounds.height / 2
        copyButton.setTitle("", for: .normal)
        
        AssetImageLoader.shared.loadAssetIcon(
            into: assetImage,
            iconUrl: viewModel.asset.iconUrl,
            symbol: viewModel.asset.asset?.symbol ?? ""
        )
        
        assetName.text = viewModel.asset.asset?.name
        assetBlockchainName.text = viewModel.asset.asset?.blockchain
        assetAddressTitle.text = "\(viewModel.asset.asset?.symbol ?? "") address"
        assetAddress.text = viewModel.getAssetAddress()
        
        qrCodeImage.image = getQRCodeImage()
        
        let headerRootView = ReceiveAssetHeaderView(asset: viewModel.asset)
        let headerSwiftUIView = addSwiftUIView(rootView: AnyView(headerRootView), container: headerContainer)
        headerSwiftUIView.backgroundColor = AssetsColors.background.getColor()

        let rootView = DetailsListItemView(title: LocalizableStrings.walletAddress, contentText: viewModel.getAssetAddress(), showCopyButton: true)
        let swiftUIView = addSwiftUIView(rootView: AnyView(rootView), container: addressBackground)
        swiftUIView.backgroundColor = AssetsColors.gray1.getColor()
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
