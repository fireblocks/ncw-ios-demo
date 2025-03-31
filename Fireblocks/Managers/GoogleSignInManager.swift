//
//  GoogleSignInManager.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 27/06/2023.
//

import Foundation
import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import GoogleAPIClientForREST_Drive

class GoogleSignInManager: Identifiable, Equatable, Hashable, ObservableObject {
    static func == (lhs: GoogleSignInManager, rhs: GoogleSignInManager) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id = UUID().uuidString
    func getGIDConfiguration() -> GIDConfiguration? {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("GoogleSignInManager, getGIDConfiguration(): clientID is nil.")
            return nil
        }
        return GIDConfiguration(clientID: clientID)
    }
    
    let googleDriveScope = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDriveAppdata]
}

extension GIDSignInResult: FirebaseAuthDelegate {
    func getCredentials() -> AuthCredential? {
        let user = self.user
        
        guard  let idToken = user.idToken?.tokenString else {
            print("GoogleSignInManager, getCredentials(): idToken is nil.")
            return nil
        }
        
        return GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: user.accessToken.tokenString
        )
    }
}
