//
//  ManuallyInputViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 06/07/2023.
//

import Foundation
import UIKit
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

protocol ManuallyInputDelegate: AnyObject {
    func isWalletRecovered(_ isRecovered: Bool) async
}

final class ManuallyInputViewModel {
    
    private var isInputContentHidden = false
    private var inputContent: String = ""
    private var preparedInputContent: String = ""
    private var task: Task <Void, Never>?
    var didComeFromGenerateKeys = false

    deinit {
        task?.cancel()
        task = nil
    }
    
    func setInputContent(_ inputContent: String, isHidden: Bool) {
        self.inputContent = inputContent
        self.isInputContentHidden = isHidden
    }
    
    func toggleIsKeyHidden() {
        isInputContentHidden.toggle()
    }

    func getIsInputContentHidden() -> Bool {
        return isInputContentHidden
    }
    
    func getPassPhraseForTextView() -> String {
        return isInputContentHidden ? inputContent.map { _ in "• " }.joined() : inputContent
    }
    
    func getHideIconOfPassPhrase() -> UIImage? {
        let assetIcon = isInputContentHidden ? AssetsIcons.eye : AssetsIcons.eyeCrossedOut
        return assetIcon.getIcon()
    }
    
    func writeToClipboard() {
        UIPasteboard.general.string = inputContent
    }
    
    func recoverWallet(_ delegate: ManuallyInputDelegate, _ passPhrase: String) {
        task = Task {
            let isRecovered = await FireblocksManager.shared.recoverWallet(resolver: self)
            await delegate.isWalletRecovered(isRecovered)
        }
    }
    
    func setInputContent(input: String) {
        inputContent = input
    }
}

extension ManuallyInputViewModel: FireblocksPassphraseResolver {
    func resolve(passphraseId: String, callback: @escaping (String) -> ()) {
        
    }
}
