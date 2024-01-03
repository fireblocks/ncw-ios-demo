//
//  MpcKeysViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 12/07/2023.
//

import Foundation

protocol MpcKeysViewModelDelegate: AnyObject {
    func configSuccessUI()
    func showAlertMessage(message: String)
}

final class MpcKeysViewModel {
    
    private var incomingMessageTask: Task<Void, Never>?
    private var mpcKeyTask: Task<Void, Never>?
    var didSucceedGenerateKeys = false
    var isAddingDevice: Bool
    weak var delegate: MpcKeysViewModelDelegate?
    
    init(isAddingDevice: Bool) {
        self.isAddingDevice = isAddingDevice
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
            await FireblocksManager.shared.addDevice(self)
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
