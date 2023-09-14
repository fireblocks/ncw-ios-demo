//
//  ManuallyInputViewControllerStrategy.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 21/07/2023.
//

import Foundation

protocol ManuallyInputViewControllerStrategy {
    var inputContent: String { get set }
    var isInputContentHidden: Bool { get }
    var inputContentIsEditable: Bool { get }
    var viewControllerTitle: String { get }
    var explanation: String { get }
    var deleteContentButtonIsHidden: Bool { get }
    var copyButtonTitle: String { get }
    var copyButtonIsHidden: Bool { get }
    var recoverButtonIsHidden: Bool { get }
}

struct ManuallyBackup: ManuallyInputViewControllerStrategy {
    var inputContent: String
    var isInputContentHidden: Bool = true
    var inputContentIsEditable: Bool = false
    let viewControllerTitle: String = LocalizableStrings.createKeyBackup
    let explanation: String = LocalizableStrings.saveRecoveryKey
    let deleteContentButtonIsHidden: Bool = true
    let copyButtonTitle: String = LocalizableStrings.copyRecoveryKey
    let copyButtonIsHidden: Bool = false
    let recoverButtonIsHidden: Bool = true
}

struct ManuallyRecover: ManuallyInputViewControllerStrategy {
    var inputContent: String
    var isInputContentHidden: Bool = false
    var inputContentIsEditable: Bool = true
    let viewControllerTitle: String = LocalizableStrings.recoverWalletTitle
    let explanation: String = LocalizableStrings.copyAndPasteYourRecoveryKey
    let deleteContentButtonIsHidden: Bool = false
    let copyButtonTitle: String = ""
    let copyButtonIsHidden: Bool = true
    let recoverButtonIsHidden: Bool = false
}

struct ManuallyTakeover: ManuallyInputViewControllerStrategy {
    var inputContent: String
    var isInputContentHidden: Bool = true
    var inputContentIsEditable: Bool = false
    let viewControllerTitle: String = LocalizableStrings.exportPrivateKeyTitle
    let explanation: String = LocalizableStrings.createPrivateKey
    let deleteContentButtonIsHidden: Bool = true
    let copyButtonTitle: String = LocalizableStrings.copyKey
    let copyButtonIsHidden: Bool = false
    let recoverButtonIsHidden: Bool = true
}
