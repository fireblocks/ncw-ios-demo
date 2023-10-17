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
    private var assetsSummary: [AssetSummary] = []
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
    
    func createAssets() {
        Task {
            await repository.createAssets()
            fetchAssets()
        }

    }
    
    func fetchAssets() {
        task = Task {
            do {
                let assetResponse = try await repository.getAssets()
                assetsSummary = assetResponse.map({$0.value})
                assets = assetsSummary.filter({$0.asset != nil}).map({$0.asset!})
                fetchBalance()
            } catch let error {
                print(error.localizedDescription)
                delegate?.gotError()
            }
        }
    }
    
    private func fetchBalance() {
        for i in 0..<assets.count {
            if let assetSummary = assetsSummary.first(where: {$0.asset?.id == assets[i].id}), let balance = assetSummary.balance, let address = assetSummary.address {
                assets[i].balance = Double(balance.total)?.formatFractions(fractionDigits: 6)
                if let balance = assets[i].balance, let rate = assets[i].rate {
                    assets[i].price = (balance * rate).formatFractions(fractionDigits: 2)
                }
                
                assets[i].address = address.address
            }
        }

        delegate?.refreshData()
    }
    
    func getAssets() -> [Asset] {
        assets.sorted(by: {$0.name < $1.name})
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
