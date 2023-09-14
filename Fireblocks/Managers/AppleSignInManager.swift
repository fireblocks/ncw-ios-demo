//
//  AppleSignInManager.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 27/06/2023.
//

import Foundation
import CryptoKit
import AuthenticationServices
import FirebaseAuth

class AppleSignInManager {
    
    static var currentNonce: String?
    
    func getAppleRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = getNonceInSha256()
        return request
    }
    
    private func getNonceInSha256() -> String {
        AppleSignInManager.currentNonce = randomNonceString()
        return sha256(AppleSignInManager.currentNonce!)
    }
    
    /*
     Note! Does not modify the current function.
     The randomNonceString function is a utility function from Firebase.
     It generates a random string, used as a nonce in security protocols for apple requests.
     */
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}

extension ASAuthorization: FirebaseAuthDelegate {
    func getCredentials() -> AuthCredential? {
        guard let appleIDCredential = self.credential as? ASAuthorizationAppleIDCredential else {
            print("Can't create appleIDCredential from authorization.credential")
            return nil
        }
        
        guard let nonce = AppleSignInManager.currentNonce else {
            print("Invalid state: A login callback was received, but no login request was sent.")
            return nil
        }
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return nil
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return nil
        }
        
        return OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
    }
}
