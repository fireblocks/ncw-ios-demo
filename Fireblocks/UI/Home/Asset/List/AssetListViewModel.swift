//
//  AssetListViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 15/06/2023.
//

import Foundation
import Combine

protocol AssetListViewModelDelegate: AnyObject {
    func refreshData()
    func refreshSection(section: Int)
    func gotError()
    func navigateToNextScreen(with asset: Asset)
}

class AssetListViewModel {
    weak var delegate: AssetListViewModelDelegate?
    private var assetsSummary: [AssetSummary] = []
    private var assets: [Asset] = []
    private let repository = AssetListRepository()
    private var task: Task<Void, Never>?
    var cancellable = Set<AnyCancellable>()
    var chooseAssetFlowType: ChooseAssetFlowType = .send

    static let shared = AssetListViewModel()

    private init() {}
    
    func signOut() {
        assets.removeAll()
        cancellable.removeAll()
    }
    
    deinit {
        task?.cancel()
    }
    
    func listenToTransferChanges() {
        TransfersViewModel.shared.$transfers.receive(on: RunLoop.main)
            .sink { [weak self] transfers in
                if let self {
                    self.task?.cancel()
                    self.fetchAssets()
                }
            }.store(in: &cancellable)
    }

    func fetchAssets() {
        task = Task {
            do {
                let assetResponse = try await repository.getAssets()
                DispatchQueue.main.async {
                    self.assetsSummary = assetResponse.map({$0.value})
                    let newAssets = self.assetsSummary.filter({$0.asset != nil}).map({$0.asset!})
                    var tempAssets: [Asset] = []
                    for asset in newAssets {
                        var newAsset = asset
                        newAsset.isExpanded = self.assets.first(where: {$0 == newAsset})?.isExpanded ?? false
                        tempAssets.append(newAsset)
                    }
                    self.assets = tempAssets
                    self.fetchBalance()
                }
            } catch URLError.cancelled {
                print("URLError.cancelled")
            } catch let error as NSError {
                if Task.isCancelled {
                    print(error.localizedDescription)
                } else {
                    print(error.localizedDescription)
                    delegate?.gotError()
                }
            }
        }
    }
    
    func toggleAssetExpanded(asset: Asset, section: Int) {
        if let index = assets.firstIndex(where: {$0 == asset}) {
            assets[index].isExpanded?.toggle()
            delegate?.refreshSection(section: section)
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
    
    func getAssetSummary() -> [AssetSummary] {
        return assetsSummary
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
        
        return "$\(balanceSum.formatFractions())"
    }
    
    func getIsButtonsEnabled() -> Bool {
        return !assets.isEmpty
    }
    
    func getAsset(by assetId: String) -> Asset? {
        return assets.first(where: {$0.id == assetId})
    }
    
    func didTapSend(index: Int) {
        if assets.count > index {
            let asset = getAssets()[index]
            self.chooseAssetFlowType = .send
            delegate?.navigateToNextScreen(with: asset)
        }
    }
    
    func didTapReceive(index: Int) {
        if assets.count > index {
            let asset = getAssets()[index]
            self.chooseAssetFlowType = .receive
            delegate?.navigateToNextScreen(with: asset)
        }
    }

    
}
