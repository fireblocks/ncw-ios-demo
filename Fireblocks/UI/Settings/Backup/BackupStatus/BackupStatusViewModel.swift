//
//  BackupStatusViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 03/10/2023.
//

import Foundation

class BackupStatusViewModel {
    var didComeFromGenerateKeys: Bool
    
    init(didComeFromGenerateKeys: Bool) {
        self.didComeFromGenerateKeys = didComeFromGenerateKeys
    }
}
