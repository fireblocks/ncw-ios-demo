//
//  SessionManager.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 15/01/2025.
//
import Foundation
import UIKit

class SessionManager: ObservableObject {
    var isLoggedIn = false
    var ewManager = EWManager.shared
    
    enum FBURL {
        case joinWallet(String)

        var url: String {
            switch self {
            case .joinWallet(let deviceId):
                return EnvironmentConstants.baseURL + "/api/devices/\(deviceId)/join"
            }
            
        }
        
        var timeout: TimeInterval? {
            switch self {
            case .joinWallet(_):
                return 30.0
            }
        }
    }
    
    static let shared = SessionManager()
    
    private init() {}
    
    func loadImage(url: URL) async throws -> UIImage {
        if let image = CacheManager.shared.getImage(url: url) {
            return image
        }
        
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let (data, response) = try await session.data(for: request)
        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            if statusCode >= 200, statusCode <= 299 {
                if let image = UIImage(data: data) {
                    CacheManager.shared.addImage(url: url, image: image)
                    return image
                }
                throw SessionManager.error
            } else {
                print("SessionManager Error statusCode: \(statusCode)")
                throw SessionManager.error
            }
        } else {
            print("SessionManager Error")
            throw SessionManager.error
        }

    }
    
    func sendRequest(url: URL, httpMethod: String = "POST", timeout: TimeInterval? = nil, numberOfRetries: Int = 2, message: String? = nil, body: Any? = nil, skipLogs: Bool = false) async throws -> (Data) {
        guard let currentAccessToken = await AuthRepository.getUserIdToken() else {
            throw SessionManager.error
        }
        
        var request = URLRequest(url: url)
        request.setValue(
            "Bearer \(currentAccessToken)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpMethod = httpMethod
        if let timeout = timeout {
            request.timeoutInterval = timeout
        }
        
        if httpMethod != "GET" {
            var body = body
            if let message {
                body = ["message": message]
            }
            if let body {
                let bodyData = try? JSONSerialization.data(
                    withJSONObject: body,
                    options: []
                )
                request.httpBody = bodyData
            }
        }
        
        let session = URLSession.shared
        AppLoggerManager.shared.logger()?.log("\n📣📣📣📣\nSessionManager send request:\n\(request)\n📣📣📣📣")
        AppLoggerManager.shared.logger()?.log("SessionManager REQUEST: \(String(describing: request)) message: \(message ?? ""), body: \(body ?? "")")
        print("\(Date().milliseconds()) SessionManager REQUEST: \(String(describing: request))")
        let (data, response) = try await session.data(for: request)
        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            if statusCode >= 200, statusCode <= 299 {
                print("\(Date().milliseconds()) SessionManager RESPONSE: \(url)\n\(String(describing: String(data: data, encoding: .utf8)))")
                AppLoggerManager.shared.logger()?.log("SessionManager Got RESPONSE")
                
                if !skipLogs {
                    AppLoggerManager.shared.logger()?.log("SessionManager RESPONSE: \(String(describing: String(data: data, encoding: .utf8)))")
                }
                return data
            } else {
                print("SessionManager Error statusCode: \(statusCode)")
                throw SessionManager.error
            }
        } else {
            print("SessionManager Error")
            throw SessionManager.error
        }
        
    }
    
    private func retry(url: URL, httpMethod: String, timeout: TimeInterval?, numberOfRetries: Int, message: String?, body: Any?, skipLogs: Bool, error: NSError) async throws -> (Data) {
        if numberOfRetries <= 0 {
            throw SessionManager.error
        } else {
            print("Retry \(url.absoluteString) - \(numberOfRetries) more retries")
            AppLoggerManager.shared.logger()?.log("Retry \(url.absoluteString) - \(numberOfRetries) more retries. Error: \(error.localizedDescription)")
            return try await self.sendRequest(url: url, httpMethod: httpMethod, timeout: timeout, numberOfRetries: numberOfRetries - 1, message: message, body: body, skipLogs: skipLogs)
        }
    }
}


extension SessionManager {
    static let error = NSError(domain: "Networking", code: 0, userInfo: [NSLocalizedDescriptionKey : "Networking Error"])
    
    static func appError(code: Int) -> NSError {
        return NSError(domain: "Networking", code: code, userInfo: [NSLocalizedDescriptionKey : "Networking Error"])
    }
    
    func joinWallet(deviceId: String, walletId: String) async throws -> Bool? {
        return true
    }

    func getLatestBackupInfo(walletId: String, deviceId: String? = nil) async throws -> BackupInfo {
        if let deviceId, let response = try? await ewManager.getLatestBackup() {
            if let key = response.keys?.first(where: {$0.deviceId == deviceId}) {
                return BackupInfo(passphraseId: response.passphraseId, deviceId: key.deviceId, location: .GoogleDrive, createdAt: response.createdAt)
            }
        }
        
        return BackupInfo()
    }
    
    func getPassphraseInfos() async throws -> PassphraseInfos {
        return PassphraseInfos(passphrases: [])
    }
    
    func createPassphraseInfo(passphraseInfo: PassphraseInfoBody) async throws {
    }

}
