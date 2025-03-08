////
////  BackupDetailsViewModel.swift
////  Fireblocks
////
////  Created by Fireblocks Ltd. on 16/07/2023.
////
//
//import UIKit
//
//class BackupDetailsViewModel {
//    
//    private var backupData: BackupData?
//    
//    func setBackupData(_ backupData: BackupData?) {
//        self.backupData = backupData
//    }
//    
//    func getAccountAssociatedWithLastBackup() -> String {
//        return ""
//    }
//    
//    func getBackupDetails() -> NSAttributedString {
//        let backupDate = backupData?.date ?? "-"
//        let backupDetails = LocalizableStrings.backupDateAndAccount
//            .replacingOccurrences(of: "{date}", with: backupDate)
//            .replacingOccurrences(of: "{backup_provider}", with: backupData?.title ?? "-")
//        
//        return makeSelectedTextBold(text: backupDetails, boldSubstring: backupDate)
//    }
//    
//    private func makeSelectedTextBold(text: String, boldSubstring: String) -> NSAttributedString {
//        let attributedString = NSMutableAttributedString(string: text)
//        let range = (text as NSString).range(of: boldSubstring)
//        
//        if range.location != NSNotFound {
//            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: range)
//        }
//        
//        return attributedString
//    }
//}
