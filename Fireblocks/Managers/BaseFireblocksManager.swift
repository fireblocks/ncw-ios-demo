//
//  BaseFireblocksManager.swift
//  Fireblocks
//
//  Created by Claude on 15/01/2025.
//

import Foundation
import SwiftUI

#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

class BaseFireblocksManager: ObservableObject {
    
    // MARK: - Events Management
    @Published var eventsList: [FireblocksEvent] = []
    private let eventsQueue = DispatchQueue(label: "fireblocks.events", qos: .utility)
    
    // MARK: - Biometric Error Management
    private var latestBiometricError: String?
    
    // MARK: - Initialization
    init() {
        setupBiometricErrorObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Event Handler
    func createEventHandlerDelegate() -> EventHandlerDelegate {
        return BaseEventHandler(manager: self)
    }
    
    // MARK: - Event Management Methods
    func addEvent(_ event: FireblocksEvent) {
        eventsQueue.async {
            DispatchQueue.main.async {
                self.eventsList.append(event)
                self.logEvent(event)
            }
        }
    }
    
    func clearEvents() {
        eventsQueue.async {
            DispatchQueue.main.async {
                self.eventsList.removeAll()
            }
        }
    }
    
    func getEvents() -> [FireblocksEvent] {
        return eventsList
    }
    
    func getError(_ eventType: FireblocksEventType, defaultError: Error)-> Error {
        let specificErrorMessage = getLatestEventErrorByType(eventType)
        let biometricErrorMessage = getBiometricErrorMessage()
        
        // Aggregate error messages nicely
        let combinedMessage: String?
        if let specificError = specificErrorMessage, let biometricError = biometricErrorMessage {
            combinedMessage = "\(specificError)\n\n\(biometricError)"
        } else if let specificError = specificErrorMessage {
            combinedMessage = specificError
        } else if let biometricError = biometricErrorMessage {
            combinedMessage = biometricError
        } else {
            combinedMessage = nil
        }
        
        let error = if let message = combinedMessage {
            CustomError.genericError(message)
        } else {
            defaultError
        }
        
        // Clear the biometric error after using it
        clearBiometricError()
        
        return error
    }
    
    func getLatestEventErrorByType(_ eventType: FireblocksEventType) -> String? {
        
        // Find the latest event of the specified type and get its error
        let fireblocksError = eventsList.reversed().first { event in
            switch eventType {
            case .transaction:
                if case .Transaction = event { return true }
            case .keyCreation:
                if case .KeyCreation = event { return true }
            case .backup:
                if case .Backup = event { return true }
            case .recover:
                if case .Recover = event { return true }
            case .takeover:
                if case .Takeover = event { return true }
            case .joinWallet:
                if case .JoinWallet = event { return true }
            }
            return false
        }?.getError()
        
        switch fireblocksError?.code {
            case ErrorDescription.InvalidPhysicalDeviceId.code():
                return LocalizableStrings.invalidPhysicalDeviceId
            case ErrorDescription.IncompleteDeviceSetup.code():
                return LocalizableStrings.incompleteDeviceSetup
//                case ErrorDescription.IncompleteBackup.code():
//                    return LocalizableStrings.incompleteBackup
            default:
                return fireblocksError?.message

      
        }
    }
    
    enum FireblocksEventType {
        case transaction
        case keyCreation
        case backup
        case recover
        case takeover
        case joinWallet
    }
    
    // MARK: - Biometric Error Management Methods
    private func setupBiometricErrorObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBiometricError(_:)),
            name: Notification.Name("BiometricError"),
            object: nil
        )
    }
    
    @objc private func handleBiometricError(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let errorMessage = userInfo["errorMessage"] as? String {
            latestBiometricError = errorMessage
        }
    }
    
    private func getBiometricErrorMessage() -> String? {
        return latestBiometricError
    }
    
    private func clearBiometricError() {
        latestBiometricError = nil
    }
    
    // MARK: - Private Methods
    private func logEvent(_ event: FireblocksEvent) {
        switch event {
        case let .KeyCreation(status, error):
            AppLoggerManager.shared.logger()?.log("BaseFireblocksManager, status(.KeyCreation): \(status.description()). Error: \(String(describing: error)).")
        case let .Backup(status, error):
            AppLoggerManager.shared.logger()?.log("BaseFireblocksManager, status(.Backup): \(status.description()). Error: \(String(describing: error)).")
        case let .Recover(status, error):
            AppLoggerManager.shared.logger()?.log("BaseFireblocksManager, status(.Recover): \(String(describing: status?.description())). Error: \(String(describing: error)).")
        case let .Transaction(status, error):
            AppLoggerManager.shared.logger()?.log("BaseFireblocksManager, status(.Transaction): \(status.description()). Error: \(String(describing: error)).")
        case let .Takeover(status, error):
            AppLoggerManager.shared.logger()?.log("BaseFireblocksManager, status(.Takeover): \(status.description()). Error: \(String(describing: error)).")
        case let .JoinWallet(status, error):
            AppLoggerManager.shared.logger()?.log("BaseFireblocksManager, status(.JoinWallet): \(status.description()). Error: \(String(describing: error)).")
        @unknown default:
            AppLoggerManager.shared.logger()?.log("BaseFireblocksManager, @unknown case")
        }
    }
}

// MARK: - Base Event Handler
private class BaseEventHandler: EventHandlerDelegate {
    weak var manager: BaseFireblocksManager?
    
    init(manager: BaseFireblocksManager) {
        self.manager = manager
    }
    
    func onEvent(event: FireblocksEvent) {
        manager?.addEvent(event)
    }
}

// MARK: - FireblocksEvent Extension
extension FireblocksEvent {
    func getError() -> FireblocksError? {
        switch self {
        case let .KeyCreation(_, error):
            return error
        case let .Backup(_, error):
            return error
        case let .Recover(_, error):
            return error
        case let .Transaction(_, error):
            return error
        case let .Takeover(_, error):
            return error
        case let .JoinWallet(_, error):
            return error
        @unknown default:
            return nil
        }
    }
}
