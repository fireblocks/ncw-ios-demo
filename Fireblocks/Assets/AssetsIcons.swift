//
//  AssetsIcons.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 14/06/2023.
//

import Foundation
import UIKit.UIImage

enum AssetsIcons: String {
    case appleIcon = "apple_icon"
    case arrowRight = "arrow_right"
    case back = "back"
    case backup = "backup"
    case checkMark = "check_mark"
    case close = "close"
    case copy = "copy"
    case error = "error"
    case eyeCrossedOut = "eye_crossed_out"
    case eye = "eye"
    case googleIcon = "google_icon"
    case home = "home"
    case info = "info"
    case key = "key"
    case plus = "plus"
    case receive = "receive"
    case recover = "recover"
    case refresh = "refresh"
    case save = "save"
    case scanQrCode = "scan_qr_code"
    case send = "send"
    case settings = "settings"
    case warning = "warning"
    case transfer = "transfer"
    case wallet = "wallet"
    case addNewDevice = "addNewDevice"
    case shareLogs = "shareLogs"

    case profilePlaceholder = "profile_placeholder"
    case cancelTransaction = "cancel_transaction"
    case signOut = "sign_out"
    
    case BitcoinIcon = "bitcoin_icon"
    case EthereumIcon = "ethereum_icon"
    case PlaceholderIcon = "placeholder_icon"
    case SolanaIcon = "solana_icon"
    case AdaIcon = "ada"
    case AvaxIcon = "avax"
    case MaticIcon = "matic"
    case USDTIcon = "usdt"
    case USDCIcon = "usdc"
    case DaiIcon = "dai"
    case ShibIcon = "shib"
    case UniIcon = "uni"
    case XrpIcon = "xrp"
    case DotIcon = "dot"
    case CeloAlfIcon = "celo"




    case errorImage = "error_image"
    case generateKeyImage = "generate_key_image"
    case keyImage = "key_image"
    case searchImage = "search_image"
    case successImage = "success_image"
    case addDeviceImage = "add_device"
    case addAccountImage = "add_account"
    case existingAccountImage = "existing_account"
    case transferImage = "transfer_image"
}

extension AssetsIcons {
    func getIcon() -> UIImage {
        let imageName = self.rawValue
        guard let image = UIImage(named: imageName) else {
            print("‼️ Unable to load image asset named: \(imageName).")
            return UIImage()
        }
        
        return image
    }
}
