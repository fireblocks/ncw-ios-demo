//
//  MpcKeysViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 12/07/2023.
//

import Foundation
import FirebaseAuth
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

protocol MpcKeysViewModelDelegate: AnyObject {
    func configSuccessUI()
    func showAlertMessage(message: String)
}

final class MpcKeysViewModel {
    
    private var incomingMessageTask: Task<Void, Never>?
    private var mpcKeyTask: Task<Void, Never>?
    var didSucceedGenerateKeys = false
    var email: String?
    weak var delegate: MpcKeysViewModelDelegate?
    
    init() {
        self.email = Auth.auth().currentUser?.email
    }
    
    deinit {
        cancelTasks()
    }
    
    func generateMpcKeys() {
        generateMpcFromSdk(self)
    }
    
    func generateEDDSAKeys() {
        generateEDDSAKeys(self)
    }
    
    func generateECDSAKeys() {
        generateECDSAKeys(self)
    }
    
    private func generateMpcFromSdk(_ delegate: FireblocksKeyCreationDelegate) {
        mpcKeyTask = Task {
            let result = await FireblocksManager.shared.generateMpcKeys()
            handleResult(result: result, delegate: delegate)
        }
    }
    
    private func generateEDDSAKeys(_ delegate: FireblocksKeyCreationDelegate) {
        mpcKeyTask = Task {
            let result = await FireblocksManager.shared.generateEDDSAKeys()
            handleResult(result: result, delegate: delegate)

        }
    }
    
    private func generateECDSAKeys(_ delegate: FireblocksKeyCreationDelegate) {
        mpcKeyTask = Task {
            let result = await FireblocksManager.shared.generateECDSAKeys()
            handleResult(result: result, delegate: delegate)
        }
    }
    
    private func handleResult(result: Set<KeyDescriptor>?, delegate: FireblocksKeyCreationDelegate) {
        let isGenerated = result != nil && result!.filter({$0.keyStatus == .READY}).count > 0
        AppLoggerManager.shared.logger()?.log("FireblocksManager, generateMpcKeys() isGenerated value: \(isGenerated).")

        if isGenerated {
            FireblocksManager.shared.startPolling()
        }

        delegate.isKeysGenerated(isGenerated: isGenerated, didJoin: false, error: nil)
    }
    
    private func cancelTasks() {
        incomingMessageTask?.cancel()
        incomingMessageTask = nil
        
        mpcKeyTask?.cancel()
        mpcKeyTask = nil
    }
    
    func createAssets(){
        didSucceedGenerateKeys = true
        self.delegate?.configSuccessUI()
    }

}

//MARK: - FireblocksKeyCreationDelegate
extension MpcKeysViewModel: FireblocksKeyCreationDelegate {
    func isKeysGenerated(isGenerated: Bool, didJoin: Bool = false, error: String? = nil) {
        if didJoin {
        } else {
            if isGenerated {
                self.createAssets()
            } else {
                self.delegate?.showAlertMessage(message: error ?? LocalizableStrings.mpcKeysGenerationFailed)
            }
        }
    }
}
