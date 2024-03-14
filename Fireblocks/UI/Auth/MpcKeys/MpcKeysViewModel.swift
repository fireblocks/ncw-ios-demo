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
    func onAddingDevice(success: Bool)
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
