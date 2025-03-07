//
//  AssetListViewModelDelegate.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 15/01/2025.
//

protocol AssetListViewModelDelegate: AnyObject {
    func refreshData()
    func refreshSection(section: Int)
    func gotError()
    func navigateToNextScreen(with asset: AssetSummary)
}
