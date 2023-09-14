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

class GoogleSignInManager {
    func getGIDConfiguration() -> GIDConfiguration? {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("GoogleSignInManager, getGIDConfiguration(): clientID is nil.")
            return nil
        }
        return GIDConfiguration(clientID: clientID)
    }
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
