//
//  ICloudManager.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 18/07/2023.
//

import Foundation
import CloudKit

class ICloudManager {
    
    private var recordName = "passphrase"
    private let recordKey = "passphrase"
    private let recordType = "String"
    
    func uploadData(container: CKContainer, passPhrase: String) async -> Bool {
        await deleteRecordIfExist(container)
        return await saveNewRecord(container: container, passPhrase: passPhrase)
    }
    
    func fetchData(container: CKContainer) async -> String {
        do {
            let database = container.privateCloudDatabase
            let record = try await database.record(for: getRecordId())
            let passPhrase = record.value(forKey: recordKey) as? String ?? ""
            return passPhrase
        } catch {
            print("ICloudManager data fetching failed: \(error)")
            return ""
        }
    }
    
    private func getRecordId() -> CKRecord.ID {
        return CKRecord.ID(recordName: "\(recordName)_\(FireblocksManager.shared.getDeviceId().replaceHyphenWithUnderscore())")
    }
    
    private func getCkRecord(_ value: String) -> CKRecord {
        let record = CKRecord(recordType: recordType, recordID: getRecordId())
        record.setValue(value, forKey: recordKey)
        return record
    }
    
    private func deleteRecordIfExist(_ container: CKContainer) async {
        do {
            let _ = try await container.privateCloudDatabase.deleteRecord(withID: getRecordId())
        } catch {
            print("ICloudManager, deleteRecordIfExist() failed: \(error)")
        }
    }
    
    private func saveNewRecord(container: CKContainer, passPhrase: String) async -> Bool {
        do {
            let _ = try await container.privateCloudDatabase.save(getCkRecord(passPhrase))
            return true
        } catch {
            print("ICloudManager uploading failed: \(error)")
            return false
        }
    }
    
}

