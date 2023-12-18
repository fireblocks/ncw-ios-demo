//
//  GoogleDriveManager.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 17/07/2023.
//

import Foundation
import GoogleAPIClientForREST_Drive
import GoogleSignIn

final class GoogleDriveManager {
    
    private let googleDriveApiClientId = "CLIENT_ID"
    private static let fileName = "passphrase.txt"
    private var passphrase = ""
    
    func getGidConfiguration() -> GIDConfiguration? {
        var configuration: GIDConfiguration? = nil
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let infoDict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            if let clientId = infoDict[googleDriveApiClientId] as? String {
                configuration = GIDConfiguration(clientID: clientId)
            }
        }
        
        return configuration
    }

    func backupToDrive(gidUser: GIDGoogleUser, passphrase: String, passphraseId: String) async -> Bool {
        self.passphrase = passphrase
        let service = GTLRDriveService()
        service.authorizer = gidUser.fetcherAuthorizer
        
        return await withCheckedContinuation { continuation in
            service.executeQuery(getUploadQuery(passphraseId: passphraseId)) { ticket, file, error in
                continuation.resume(returning: error == nil )
            }
        }
    }
    
    func recoverFromDrive(gidUser: GIDGoogleUser, passphraseId: String) async -> String? {
        let service = GTLRDriveService()
        service.authorizer = gidUser.fetcherAuthorizer
        let googleDriveFileId = await getGoogleDriveFileId(service: service, passphraseId: passphraseId)
        let passPhrase = await getPassPhrase(service: service, fileID: googleDriveFileId)
        return passPhrase
    }
    
    private func getGoogleDriveFileId(service: GTLRDriveService, passphraseId: String) async -> String? {
        return await withCheckedContinuation { continuation in
            service.executeQuery(getSearchQuery()) { ticket, result, error in
                let files = (result as? GTLRDrive_FileList)?.files
                let identifier: String? = files?.filter({$0.name != nil}).first(where: {$0.name!.hasPrefix("passphrase_\(passphraseId)")})?.identifier
                continuation.resume(returning: identifier)
            }
        }
    }
    
    private func getPassPhrase(service: GTLRDriveService, fileID: String?) async -> String? {
        guard let fileID else { return nil }
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileID)
        return await withCheckedContinuation { continuation in
            service.executeQuery(query) { (ticket, result, error) in
                let data = (result as? GTLRDataObject)?.data ?? Data()
                let string = String(data: data, encoding: .utf8)
                continuation.resume(returning: string)
            }
        }
    }
    
    private func getSearchQuery() -> GTLRDriveQuery_FilesList {
        let query = GTLRDriveQuery_FilesList.query()
        query.spaces = "appDataFolder"
        return query
    }
    
    private func getUploadQuery(passphraseId: String) -> GTLRDriveQuery_FilesCreate {
        let query = GTLRDriveQuery_FilesCreate.query(
            withObject: getGoogleDriveFile(passphraseId: passphraseId),
            uploadParameters: getGoogleDriveParamsWithData()
        )
        query.fields = "id, parents"
        return query
    }
    
    private func getGoogleDriveFile(passphraseId: String) -> GTLRDrive_File {
        let file = GTLRDrive_File()
        file.name = "passphrase_\(passphraseId).txt"
        file.parents = ["appDataFolder"]
        return file
    }
    
    private func getGoogleDriveParamsWithData() -> GTLRUploadParameters {
        let data = passphrase.data(using: .utf8) ?? Data()
        let params = GTLRUploadParameters(data: data, mimeType: "[text/plain]")
        params.shouldUploadWithSingleRequest = true
        return params
    }
}
