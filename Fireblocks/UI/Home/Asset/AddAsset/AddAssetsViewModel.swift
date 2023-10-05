//
//  AddAssetsViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 04/10/2023.
//

import Foundation

protocol AddAssetsDelegate: AnyObject {
    func didLoadAssets()
    func failedToLoadAssets()
    func reloadData()
    func didAddAssets(addedAssets: [Asset], failedAssets: [Asset])
}

class AddAssetsViewModel: ObservableObject {
    private let deviceId: String
    private var assets: [Asset] = []
    private var searchResults: [Asset] = []
    private var selectedAssets: [Asset] = []
    private var addedAssets: [Asset] = []
    private var failedAssets: [Asset] = []

    weak var delegate: AddAssetsDelegate?
    
    init(deviceId: String) {
        self.deviceId = deviceId
        Task {
            do {
                let response = try await SessionManager.shared.getAssets(deviceId: deviceId).filter({$0.value.asset != nil}).map({$0.value.asset!})
                DispatchQueue.main.async {
                    self.assets = response
                    self.searchResults = response
                    self.delegate?.didLoadAssets()
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.failedToLoadAssets()
                }
            }
        }
    }
    
    func getAssetsCount() -> Int {
        return searchResults.count
    }
    
    func getAssets() -> [Asset] {
        return searchResults
    }
    
    func getSelectedCount() -> Int {
        return selectedAssets.count
    }
    
    func didSelect(indexPath: IndexPath) -> Bool {
        if searchResults.count > indexPath.row {
            let asset = searchResults[indexPath.row]
            if let index = selectedAssets.firstIndex(where: {$0 == asset}) {
                selectedAssets.remove(at: index)
                return false
            } else {
                selectedAssets.append(asset)
                return true
            }
        }
        
        return false
    }
    
    func createAsset() {
        Task {
            for asset in selectedAssets {
                if let _ = try? await SessionManager.shared.createAsset(deviceId: deviceId, assetId: asset.symbol) {
                    addedAssets.append(asset)
                } else {
                    failedAssets.append(asset)
                }
            }
            DispatchQueue.main.async {
                self.delegate?.didAddAssets(addedAssets: self.addedAssets, failedAssets: self.failedAssets)
            }
        }

    }
    
    func searchDidChange(searchText: String) {
        if searchText.isEmpty {
            searchResults = assets
        } else {
            searchResults = assets.filter({$0.name.localizedStandardContains(searchText) || $0.symbol.localizedStandardContains(searchText)})
        }
        
        self.delegate?.reloadData()
    }

}

