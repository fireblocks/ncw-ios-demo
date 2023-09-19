//
//  AssetListViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 15/06/2023.
//

import Foundation

protocol AssetListViewModelDelegate: AnyObject {
    func refreshData()
    func gotError()
}

class AssetListViewModel {
    weak var delegate: AssetListViewModelDelegate?
    private var assets: [Asset] = []
    private let repository = AssetListRepository()
    private var task: Task<Void, Never>?
    
    static let shared = AssetListViewModel()
    
    private init() {}
    
    func signOut() {
        assets.removeAll()
    }
    
    deinit {
        task?.cancel()
    }
    
    func fetchAssets() {
        task = Task {
            do {
                await repository.createAssets()
                assets = try await repository.getAssets()
                fetchBalance()
            } catch let error {
                print(error.localizedDescription)
                delegate?.gotError()
            }
        }
    }
    
    func fetchBalance() {
        task = Task {
            do {
                for i in 0..<assets.count {
                    let balance = try await repository.getBalance(assetId: assets[i].id)
                    assets[i].balance = Double(balance.total)?.formatFractions(fractionDigits: 6)
                    if let balance = assets[i].balance, let rate = assets[i].rate {
                        assets[i].price = (balance * rate).formatFractions(fractionDigits: 2)
                    }

                    let address = try await repository.getAddress(assetId: assets[i].id)
                    assets[i].address = address.address
                }

                delegate?.refreshData()
            } catch let error {
                print(error.localizedDescription)
                delegate?.gotError()
            }
        }
    }
    
    func getAssets() -> [Asset] {
        assets
    }
    
    func getAssetsCount() -> Int {
        assets.count
    }
    
    func getBalance() -> String {
        var balanceSum: Double = 0.0
        assets.forEach { asset in
            if let price = asset.price {
                balanceSum += price 
            }
        }
        
        return "$\(balanceSum)"
    }
    
    func getIsButtonsEnabled() -> Bool {
        return !assets.isEmpty
    }
    
    func getAsset(by assetId: String) -> Asset? {
        return assets.first(where: {$0.id == assetId})
    }
}
