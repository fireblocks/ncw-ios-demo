//
//  PollingManager.swift
//  SDKDemoApp
//
//  Created by Fireblocks Ltd. on 30/08/2023.
//

import Foundation
import FireblocksDev
import SwiftUI

class PollingManager: ObservableObject {
    private var listeners: [String: PollingListener] = [:]
    
    static let shared = PollingManager()
    private init(){}
    
    func createListener(deviceId: String, instance: PollingListenerDelegate, sessionManager: SessionManager) {
        print("PollingManager: createListener \(deviceId)")
        listeners[deviceId] = PollingListener(deviceId: deviceId, sessionManager: sessionManager, instance: instance)
    }
    
    func startPolling(deviceId: String) {
        print("PollingManager: startPolling \(deviceId)")
        listeners[deviceId]?.startPolling()
    }
    
    func stopPolling(deviceId: String) {
        print("PollingManager: stopPolling \(deviceId)")
        listeners[deviceId]?.stopPolling()
    }
    
    func removeListener(deviceId: String) {
        print("PollingManager: remove listener \(deviceId)")
        stopPolling(deviceId: deviceId)
        listeners[deviceId] = nil
    }
    
    func removeAllListeners() {
        print("PollingManager: remove all")
        listeners.keys.forEach { deviceId in
            removeListener(deviceId: deviceId)
        }
    }

}
