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
    private let recordKey = "phrase"
    private let recordType = "Backup"
    
    func uploadData(container: CKContainer, passPhrase: String, passphraseId: String) async -> Bool {
        await deleteRecordIfExist(container, passphraseId: passphraseId)
        return await saveNewRecord(container: container, passPhrase: passPhrase, passphraseId: passphraseId)
    }
    
    func fetchData(container: CKContainer, passphraseId: String) async -> String? {
        do {
            let database = container.privateCloudDatabase
            let record = try await database.record(for: getRecordId(passphraseId: passphraseId))
            let passPhrase = record.value(forKey: recordKey) as? String ?? ""
            return passPhrase
        } catch {
            print("ICloudManager data fetching failed: \(error)")
            return nil
        }
    }
    
    private func getRecordId(passphraseId: String) -> CKRecord.ID {
        return CKRecord.ID(recordName: "backup_t_\(passphraseId)")
    }
    
    private func getCkRecord(_ value: String, passphraseId: String) -> CKRecord {
        let record = CKRecord(recordType: recordType, recordID: getRecordId(passphraseId: passphraseId))
        record.setValue(value, forKey: recordKey)
        return record
    }
    
    private func deleteRecordIfExist(_ container: CKContainer, passphraseId: String) async {
        do {
            let state = try await container.privateCloudDatabase.deleteRecord(withID: getRecordId(passphraseId: passphraseId))
            print(state)
        } catch {
            print("ICloudManager, deleteRecordIfExist() failed: \(error)")
        }
    }
    
    private func saveNewRecord(container: CKContainer, passPhrase: String, passphraseId: String) async -> Bool {
        do {
            let record = getCkRecord(passPhrase, passphraseId: passphraseId)
            record["phrase"] = passPhrase as CKRecordValue
            let state = try await container.privateCloudDatabase.save(record)
            return true
        } catch {
            print("ICloudManager uploading failed: \(error)")
            return false
        }
    }
    
}

