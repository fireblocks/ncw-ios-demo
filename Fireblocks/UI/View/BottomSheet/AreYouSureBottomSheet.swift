//
//  ConfirmationBottomSheet.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 22/06/2023.
//

import UIKit

protocol UserActionDelegate: AnyObject {
    func confirmButtonClicked()
}

class AreYouSureBottomSheet: UIViewController {
    
    static let identifier = "AreYouSureBottomSheet"
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var drawerLine: UIView!
    @IBOutlet weak var bottomSheetHeight: NSLayoutConstraint!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var confirmButton: AppActionBotton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet var contentView: UIView!
    
    private weak var delegate: UserActionDelegate?
    
    private var icon: AssetsIcons!
    private var message: String!
    private var confirmButtonTitle: String!
    private var cancelButtonTitle: String!
    private var actionButtonType: ButtonStyle!
    
    override func loadView() {
        super.loadView()
        loadXib()
        configureUi()
    }
    
    private func loadXib(){
        Bundle.main.loadNibNamed(AreYouSureBottomSheet.identifier, owner: self, options: nil)
        view.addSubview(contentView)
    }
    
    private func configureUi(){
        if let navigationController = navigationController {
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        drawerLine.layer.cornerRadius = drawerLine.frame.height / 2
        contentImageView.image = icon.getIcon()
        messageLabel.text = message
        confirmButton.config(title: confirmButtonTitle, style: actionButtonType)
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                backgroundView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonClicked(_ sender: AppActionBotton) {
        self.dismiss(animated: true)
        delegate?.confirmButtonClicked()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    class Builder {
        
        private weak var delegate: UserActionDelegate?
        
        private var icon: AssetsIcons = AssetsIcons.searchImage
        private var message: String = LocalizableStrings.areYouSure
        private var confirmButtonTitle: String = LocalizableStrings.confirm
        private var cancelButtonTitle: String = LocalizableStrings.neverMind
        private var actionButtonType: ButtonStyle = .Primary
        
        func setUserActionDelegate(_ delegate: UserActionDelegate) -> Builder {
            self.delegate = delegate
            return self
        }
        
        func setActionButtonType(_ type: ButtonStyle) -> Builder {
            self.actionButtonType = type
            return self
        }
        
        func setIcon(_ icon: AssetsIcons) -> Builder {
            self.icon = icon
            return self
        }
        
        func setMessage(_ message: String) -> Builder {
            self.message = message
            return self
        }
        
        func setConfirmButtonTitle(_ title: String) -> Builder {
            self.confirmButtonTitle = title
            return self
        }
        
        func setCancelButtonTitle(_ title: String) -> Builder {
            self.cancelButtonTitle = title
            return self
        }
        
        func build() -> AreYouSureBottomSheet {
            let bottomSheet = AreYouSureBottomSheet()
            
            bottomSheet.delegate = self.delegate
            bottomSheet.icon = self.icon
            bottomSheet.message = self.message
            bottomSheet.confirmButtonTitle = self.confirmButtonTitle
            bottomSheet.cancelButtonTitle = self.cancelButtonTitle
            bottomSheet.actionButtonType = self.actionButtonType
            
            return bottomSheet
        }
    }
}
