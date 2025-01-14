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
        mpcKeyTask = Task {
            let result = await FireblocksManager.shared.generateMpcKeys()
            handleResult(result: result)
        }
    }
    
    func generateEDDSAKeys() {
        mpcKeyTask = Task {
            let result = await FireblocksManager.shared.generateEDDSAKeys()
            handleResult(result: result)
            
        }
    }
    
    func generateECDSAKeys() {
        mpcKeyTask = Task {
            let result = await FireblocksManager.shared.generateECDSAKeys()
            handleResult(result: result)
        }
    }
    
    private func handleResult(result: Set<KeyDescriptor>?) {
        let isGenerated = result != nil && result!.filter({$0.keyStatus == .READY}).count > 0
        AppLoggerManager.shared.logger()?.log("FireblocksManager, generateMpcKeys() isGenerated value: \(isGenerated).")
        
        if isGenerated {
            FireblocksManager.shared.startPolling()
        }
        
        isKeysGenerated(isGenerated: isGenerated, error: nil)
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
    
    func isKeysGenerated(isGenerated: Bool, error: String? = nil) {
        if isGenerated {
            self.createAssets()
        } else {
            self.delegate?.showAlertMessage(message: error ?? LocalizableStrings.mpcKeysGenerationFailed)
        }
    }
    
}
