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
        case registerToken

        var url: String {
            switch self {
            case .joinWallet(let deviceId):
                return EnvironmentConstants.baseURL + "/api/devices/\(deviceId)/join"
            case .registerToken:
                return EnvironmentConstants.baseURL + "/api/notifications/register-token"
            }
        }
        
        var timeout: TimeInterval? {
            switch self {
            case .joinWallet(_):
                return 30.0
            case .registerToken:
                return 30.0
            }
        }
    }
    
    static let shared = SessionManager()
    
    private init() {}
    
    func loadImage(url: URL) async throws -> UIImage {
        if let image = CacheManager.shared.getImage(url: url) {
//            print("Image loaded from cache, url: \(url)")
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
                print("SessionManager loadImage Error statusCode: \(statusCode)")
                throw SessionManager.error
            }
        } else {
            print("SessionManager Error")
            throw SessionManager.error
        }

    }
    
//    func constructImageURL(iconUrl: String?, symbol: String) -> String? {
//        if iconUrl?.isEmpty ?? true, !symbol.isEmpty {
//            let formattedSymbol = symbol.replacingOccurrences(of: "_TEST\\d*$", with: "", options: .regularExpression).lowercased()
//            return "https://assets.coincap.io/assets/icons/\(formattedSymbol)@2x.png"
//        }
//        return iconUrl
//    }
    
    func sendRequest(url: URL, httpMethod: String = "POST", timeout: TimeInterval? = nil, numberOfRetries: Int = 2, message: String? = nil, body: Any? = nil, skipLogs: Bool = false) async throws -> (Data) {
        guard let currentAccessToken = await AuthRepository.getUserIdToken() else {
            AppLoggerManager.shared.logger()?.log("SessionManager sendRequest Error: No access token")
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
        AppLoggerManager.shared.logger()?.log("SessionManager send request:\n\(request)")
        AppLoggerManager.shared.logger()?.log("SessionManager REQUEST: \(String(describing: request)) message: \(message ?? ""), body: \(body ?? "")")
        print("\(Date().milliseconds()) SessionManager REQUEST: \(String(describing: request))")
        let (data, response) = try await session.data(for: request)
        
        // Log x-request-id response header if present
        if let httpResponse = response as? HTTPURLResponse,
           let requestId = httpResponse.value(forHTTPHeaderField: "x-request-id") {
            print("x-request-id: \(requestId)")
            AppLoggerManager.shared.logger()?.log("x-request-id: \(requestId)")
        }
        
        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            if statusCode >= 200, statusCode <= 299 {
                print("\(Date().milliseconds()) SessionManager RESPONSE: \(url)\n\(String(describing: String(data: data, encoding: .utf8)))")
                AppLoggerManager.shared.logger()?.log("SessionManager Got RESPONSE")
                
                if !skipLogs {
                    AppLoggerManager.shared.logger()?.log("SessionManager RESPONSE: \(String(describing: String(data: data, encoding: .utf8)))")
                }
                return data
            } else {
                AppLoggerManager.shared.logger()?.error("SessionManager Error statusCode: \(statusCode)")
                throw SessionManager.error
            }
        } else {
            AppLoggerManager.shared.logger()?.error("SessionManager Error")
            throw SessionManager.error
        }
        
    }
    
    private func retry(url: URL, httpMethod: String, timeout: TimeInterval?, numberOfRetries: Int, message: String?, body: Any?, skipLogs: Bool, error: NSError) async throws -> (Data) {
        if numberOfRetries <= 0 {
            throw SessionManager.error
        } else {
            print("Retry \(url.absoluteString) - \(numberOfRetries) more retries")
            AppLoggerManager.shared.logger()?.error("Retry \(url.absoluteString) - \(numberOfRetries) more retries. Error: \(error.localizedDescription)")
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
    
    func registerToken(body: RegisterTokenBody) async throws -> RegisterTokenResponse {
        if let url = URL(string: FBURL.registerToken.url) {
            let data = try await sendRequest(url: url, httpMethod: "POST", timeout: FBURL.registerToken.timeout, body: body.dictionary())
            let decoder = JSONDecoder()
            return try decoder.decode(RegisterTokenResponse.self, from: data)
        } else {
            throw SessionManager.error
        }
    }
    

}
