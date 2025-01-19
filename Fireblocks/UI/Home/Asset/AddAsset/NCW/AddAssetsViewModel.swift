//
//  AddAssetsViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 04/10/2023.
//

import Foundation
import UIKit



class AddAssetsViewModel: ObservableObject {
    private let deviceId: String
    private var assets: [AssetToAdd] = []
    private var searchResults: [AssetToAdd] = []
    private var addedAssets: [Asset] = []
    private var failedAssets: [Asset] = []

    weak var delegate: AddAssetsDelegate?
        
    init(deviceId: String) {
        self.deviceId = deviceId
        

        Task {
            do {
                let response = try await SessionManager.shared.getSupportedAssets(deviceId: deviceId)
                DispatchQueue.main.async {
                    self.assets = response.map({AssetToAdd(asset: $0)})
                    self.searchResults = response.map({AssetToAdd(asset: $0)})
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
    
    func getAssets() -> [AssetToAdd] {
        return searchResults
    }
    
    func getSelectedCount() -> Int {
        return assets.filter({$0.isSelected}).count
    }
    
    func didSelect(indexPath: IndexPath) {
        //TBD - can be removed when switch to multi selection
        if !searchResults[indexPath.row].isSelected {
            if let index = searchResults.firstIndex(where: {$0.isSelected}) {
                searchResults[index].isSelected = false
            }
            if let index = assets.firstIndex(where: {$0.isSelected}) {
                assets[index].isSelected = false
            }
        }
        //
        
        searchResults[indexPath.row].isSelected.toggle()
        if let index = assets.firstIndex(where: {$0.asset == searchResults[indexPath.row].asset}) {
            assets[index].isSelected.toggle()
        }
        delegate?.reloadData()
    }
    
    func createAsset() {
        Task {
            for asset in assets.filter({$0.isSelected}).map({$0.asset}) {
                do {
                    if let result = try await SessionManager.shared.createAsset(deviceId: deviceId, assetId: asset.id), let data = result.data(using: .utf8) {
                        if let error = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                            failedAssets.append(asset)
                        } else {
                            addedAssets.append(asset)
                        }
                    } else {
                        failedAssets.append(asset)
                    }
                } catch {
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
            searchResults = assets.filter({$0.asset.name.localizedStandardContains(searchText) || $0.asset.symbol.localizedStandardContains(searchText)})
        }
        
        self.delegate?.reloadData()
    }

}

