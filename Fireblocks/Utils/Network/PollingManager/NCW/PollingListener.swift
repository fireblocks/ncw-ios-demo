//
//  PollingListener.swift
//  SDKDemoApp
//
//  Created by Fireblocks Ltd. on 30/08/2023.
//

import Foundation

protocol PollingListenerDelegate: AnyObject {
    func handleTransactions(transactions: [TransactionResponse])
    func lastUpdate() -> TimeInterval?
    func handleError(error: String?)
}

class PollingListener {
    private let deviceId: String
    private let sessionManager: SessionManager
    private weak var instance: PollingListenerDelegate?
    private var isPolling: Bool = false
    private var didRequestAlltransactions: Bool = false
    
    init(deviceId: String, sessionManager: SessionManager, instance: PollingListenerDelegate) {
        self.deviceId = deviceId
        self.sessionManager = sessionManager
        self.instance = instance
        startPolling()
    }
    
    func startPolling() {
        if !isPolling {
            isPolling = true
            print("PollingListener - startPolling")
            pollTransactions()
        }
    }
    
    func stopPolling() {
        print("PollingListener - startPolling")
        isPolling = false
    }
    
    private func pollTransactions() {
        guard isPolling else { return }
        let startDate: TimeInterval? = !didRequestAlltransactions ? nil : self.instance?.lastUpdate()
        Task {
            do {
                if let transactions = try await sessionManager.getTransactions(deviceId: deviceId, startDate: startDate) {
                    self.instance?.handleTransactions(transactions: transactions)
                    self.didRequestAlltransactions = true
                }
                self.pollTransactions()
            } catch {
                self.instance?.handleError(error: error.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.pollTransactions()
                }
            }
        }
    }

}



