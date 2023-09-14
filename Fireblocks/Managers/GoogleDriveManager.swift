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
    
    private static let fileName = "passphrase.txt"
    private var passphrase = ""
    
    func backupToDrive(gidUser: GIDGoogleUser, passphrase: String) async -> Bool {
        self.passphrase = passphrase
        let service = GTLRDriveService()
        service.authorizer = gidUser.fetcherAuthorizer
        
        return await withCheckedContinuation { continuation in
            service.executeQuery(getUploadQuery()) { ticket, file, error in
                continuation.resume(returning: error == nil )
            }
        }
    }
    
    func recoverFromDrive(gidUser: GIDGoogleUser) async -> String {
        let service = GTLRDriveService()
        service.authorizer = gidUser.fetcherAuthorizer
        let googleDriveFileId = await getGoogleDriveFileId(service: service)
        let passPhrase = await getPassPhrase(service: service, fileID: googleDriveFileId)
        return passPhrase
    }
    
    private func getGoogleDriveFileId(service: GTLRDriveService) async -> String {
        return await withCheckedContinuation { continuation in
            service.executeQuery(getSearchQuery()) { ticket, result, error in
                let files = (result as? GTLRDrive_FileList)?.files
                let identifier: String = files?.filter({$0.name != nil}).first(where: {$0.name!.hasPrefix(FireblocksManager.shared.getDeviceId())})?.identifier ?? ""
                continuation.resume(returning: identifier)
            }
        }
    }
    
    private func getPassPhrase(service: GTLRDriveService, fileID: String) async -> String {
        let query = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileID)
        return await withCheckedContinuation { continuation in
            service.executeQuery(query) { (ticket, result, error) in
                let data = (result as? GTLRDataObject)?.data ?? Data()
                let string = String(data: data, encoding: .utf8)
                continuation.resume(returning: string ?? "")
            }
        }
    }
    
    private func getSearchQuery() -> GTLRDriveQuery_FilesList {
        let query = GTLRDriveQuery_FilesList.query()
        query.spaces = "appDataFolder"
        return query
    }
    
    private func getUploadQuery() -> GTLRDriveQuery_FilesCreate {
        let query = GTLRDriveQuery_FilesCreate.query(
            withObject: getGoogleDriveFile(),
            uploadParameters: getGoogleDriveParamsWithData()
        )
        query.fields = "id, parents"
        return query
    }
    
    private func getGoogleDriveFile() -> GTLRDrive_File {
        let file = GTLRDrive_File()
        file.name = "\(FireblocksManager.shared.getDeviceId())_\(GoogleDriveManager.fileName)"
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
