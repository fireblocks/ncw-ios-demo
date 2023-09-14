//
//  FirebaseAuthDelegate.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 27/06/2023.
//

import FirebaseAuth

protocol FirebaseAuthDelegate {
    func getCredentials() -> AuthCredential?
}
