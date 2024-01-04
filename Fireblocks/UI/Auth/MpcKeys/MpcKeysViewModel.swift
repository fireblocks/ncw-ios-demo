//
//  MpcKeysViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 12/07/2023.
//

import Foundation
import FireblocksSDK
import FirebaseAuth

protocol MpcKeysViewModelDelegate: AnyObject {
    func configSuccessUI()
    func showAlertMessage(message: String)
    func onRequestId(requestId: String)
    func onProvisionerFound()
}

final class MpcKeysViewModel {
    
    private var incomingMessageTask: Task<Void, Never>?
    private var mpcKeyTask: Task<Void, Never>?
    var didSucceedGenerateKeys = false
    var isAddingDevice: Bool
    var email: String?
    weak var delegate: MpcKeysViewModelDelegate?
    
    init(isAddingDevice: Bool) {
        self.isAddingDevice = isAddingDevice
        self.email = Auth.auth().currentUser?.email
    }
    
    deinit {
        cancelTasks()
    }
    
    func generateMpcKeys() {
        generateMpcFromSdk(self)
    }
    
    private func generateMpcFromSdk(_ delegate: FireblocksKeyCreationDelegate) {
        mpcKeyTask = Task {
            await FireblocksManager.shared.generateMpcKeys(delegate)
        }
    }
    
    func addDevice() {
        addDeviceFromSdk(self)
    }
    
    private func addDeviceFromSdk(_ delegate: FireblocksKeyCreationDelegate) {
        mpcKeyTask = Task {
            await FireblocksManager.shared.addDevice(self, joinWalletHandler: self)
        }
    }
    

    
    private func cancelTasks() {
        incomingMessageTask?.cancel()
        incomingMessageTask = nil
        
        mpcKeyTask?.cancel()
        mpcKeyTask = nil
    }
    
    func createAssets(){
        Task {
            didSucceedGenerateKeys = true
            self.delegate?.configSuccessUI()
        }
    }

}

//MARK: - FireblocksKeyCreationDelegate
extension MpcKeysViewModel: FireblocksKeyCreationDelegate {
    func isKeysGenerated(isGenerated: Bool) {
        if isGenerated {
            self.createAssets()
        } else {
            self.delegate?.showAlertMessage(message: LocalizableStrings.mpcKeysGenerationFailed)
        }
    }
}

extension MpcKeysViewModel: FireblocksJoinWalletHandler {
    func onRequestId(requestId: String) {
        self.delegate?.onRequestId(requestId: requestId)
    }
    
    func onProvisionerFound() {
        self.delegate?.onProvisionerFound()
    }
}
