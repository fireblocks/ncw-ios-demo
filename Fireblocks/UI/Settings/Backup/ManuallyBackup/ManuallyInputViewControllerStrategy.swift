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
