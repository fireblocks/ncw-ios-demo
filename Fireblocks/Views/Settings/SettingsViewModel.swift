//
//  SettingsViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import Foundation
import FirebaseAuth

extension SettingsView {
    class ViewModel: ObservableObject {
        
        private var currentUser: User? {
            get {
                return Auth.auth().currentUser
            }
        }
        
        func stopPollingMessages() {
            FireblocksManager.shared.stopPollingMessages()
        }
        
        func signOutFromFirebase() {
            do{
                try Auth.auth().signOut()
                TransfersViewModel.shared.signOut()
                AssetListViewModel.shared.signOut()
                FireblocksManager.shared.stopPollingMessages()
            }catch{
                print("SettingsViewModel can't sign out with current user: \(error)")
            }
        }
        
        func getUrlOfProfilePicture() -> URL? {
            if let photoURL = currentUser?.photoURL {
                print(photoURL)
                let highResPhotoURLString = photoURL.absoluteString.replacingOccurrences(of: "s96-c", with: "s400-c")
                return URL(string: highResPhotoURLString)
            }
            
            return nil
        }
        
        func getUserName() -> String {
            return currentUser?.displayName ?? ""
        }
        
        func getUserEmail() -> String {
            return currentUser?.email ?? ""
        }
    }

}
