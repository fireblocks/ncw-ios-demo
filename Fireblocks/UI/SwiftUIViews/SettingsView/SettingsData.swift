//
//  SettingsData.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 10/02/2025.
//

import Foundation

struct SettingsData: Identifiable, Hashable {
    static func == (lhs: SettingsData, rhs: SettingsData) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    
    let id: String = UUID().uuidString
    let icon: String
    let title: String
    let subtitle: String?
    let action: (() -> ())?
}
