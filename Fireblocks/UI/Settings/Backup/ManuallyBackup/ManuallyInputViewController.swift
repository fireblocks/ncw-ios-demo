//
//  ManuallyInputViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 05/07/2023.
//

import UIKit

class ManuallyInputViewController: UIViewController {
    
    static let identifier = "ManuallyInputViewController"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputContainerStackView: UIStackView!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var removeKeyButton: UIButton!
    @IBOutlet weak var hideKeyButton: UIButton!
    @IBOutlet weak var copyButton: AppActionBotton!
    @IBOutlet weak var recoverWalletButton: AppActionBotton!
    @IBOutlet weak var recoverErrorLabel: UILabel!
    
    private let viewModel = ManuallyInputViewModel()
    var manuallyInputStrategy: ManuallyInputViewControllerStrategy = ManuallyBackup(inputContent: "")
    
    func updateSourceView(didComeFromGenerateKeys: Bool = false) {
        viewModel.didComeFromGenerateKeys = didComeFromGenerateKeys
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.setInputContent(manuallyInputStrategy.inputContent, isHidden: manuallyInputStrategy.isInputContentHidden)
        configureUI()
    }
    
    private func configureUI() {
        inputTextView.delegate = self
        inputTextView.textContainer.maximumNumberOfLines = 1
        self.navigationItem.title = manuallyInputStrategy.viewControllerTitle
        inputTextView.isUserInteractionEnabled = manuallyInputStrategy.inputContentIsEditable
        titleLabel.text = manuallyInputStrategy.explanation
        inputTextView.text = viewModel.getPassPhraseForTextView()
        removeKeyButton.isHidden = manuallyInputStrategy.deleteContentButtonIsHidden
        copyButton.config(title: manuallyInputStrategy.copyButtonTitle,image: AssetsIcons.copy.getIcon() , style: .Secondary)
        copyButton.isHidden = manuallyInputStrategy.copyButtonIsHidden
        recoverWalletButton.config(title: LocalizableStrings.recoverWalletTitle, style: .Secondary)
        recoverWalletButton.isHidden = manuallyInputStrategy.recoverButtonIsHidden
        inputContainerStackView.addBorder(
            color: AssetsColors.gray2.getColor(),
            width: 1
        )
    }
    
    @IBAction func removeContentTapped(_ sender: UIButton) {
        if !inputTextView.text.isEmpty && viewModel.getIsInputContentHidden() {
            toggleVisibilityOfInputContent()
        }
        
        inputTextView.text = ""
        viewModel.setInputContent(input: "")
    }
    
    @IBAction func hideKeyTapped(_ sender: UIButton) {
        toggleVisibilityOfInputContent()
    }
    
    @IBAction func copeKeyTapped(_ sender: AppActionBotton) {
        viewModel.writeToClipboard()
        showToast()
    }
    
    @IBAction func recoverWalletTapped(_ sender: AppActionBotton) {
        showActivityIndicator()
        viewModel.recoverWallet(self, inputTextView.text)
    }
    
    @IBAction func goBackTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func toggleVisibilityOfInputContent() {
        viewModel.toggleIsKeyHidden()
        toggleHideKeyButtonIcon()
        toggleTextViewContent()
    }
    
    private func toggleHideKeyButtonIcon() {
        hideKeyButton.setImage(viewModel.getHideIconOfPassPhrase(), for: .normal)
    }
    
    private func toggleTextViewContent() {
        if manuallyInputStrategy.inputContentIsEditable {
            inputTextView.isUserInteractionEnabled = !viewModel.getIsInputContentHidden()
        }
        inputTextView.text = viewModel.getPassPhraseForTextView()
    }
    
    private func showErrorRecoveryFailed() {
        recoverErrorLabel.alpha = 1
        inputContainerStackView.layer.borderColor = AssetsColors.alert.getColor().cgColor
        UIView.animate(withDuration: 2, delay: 1) { [weak self] in
            guard let self = self else {
                return
            }
            self.inputContainerStackView.layer.borderColor = AssetsColors.gray2.getColor().cgColor
            self.recoverErrorLabel.alpha = 0
        }
    }
    
    private func navigateToAssetsViewController() {
        if let window = view.window {
            let rootViewController = UINavigationController()
            let vc = TabBarViewController()
            rootViewController.pushViewController(vc, animated: true)
            window.rootViewController = rootViewController
        }

//        navigationController?.popToRootViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//MARK: - UITextViewDelegate
extension ManuallyInputViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.setInputContent(input: textView.text)
        inputTextView.text = viewModel.getPassPhraseForTextView()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n")
        {
            view.endEditing(true)
            showActivityIndicator()
            viewModel.recoverWallet(self, inputTextView.text)
            return false
        }
        else
        {
            return true
        }

    }
    
    @IBAction func navigateToHomeTapped(_ sender: UIButton) {
        if viewModel.didComeFromGenerateKeys {
            let vc = TabBarViewController()
            self.navigationController?.setViewControllers([vc], animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }

}

//MARK: - ManuallyInputDelegate
extension ManuallyInputViewController: ManuallyInputDelegate {
    @MainActor
    func isWalletRecovered(_ isRecovered: Bool) async {
        hideActivityIndicator()
        if isRecovered {
            navigateToAssetsViewController()
        } else {
            showAlert(
                description: LocalizableStrings.failedToRecoverWallet,
                bottomAnchor: recoverWalletButton.topAnchor
            )
        }
    }
}
