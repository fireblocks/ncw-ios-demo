//
//  AssetListViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 15/06/2023.
//

import Foundation
import Combine

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
                    var tempSummary = assetResponse.map({$0.value})
                    for index in 0..<tempSummary.count {
                        tempSummary[index].isExpanded = self.assetsSummary.first(where: {$0 == tempSummary[index]})?.isExpanded ?? false
                    }
                    self.assetsSummary = tempSummary
                    let newAssets = self.assetsSummary.filter({$0.asset != nil}).map({$0.asset!})
                    var tempAssets: [Asset] = []
                    for asset in newAssets {
                        let newAsset = asset
//                        newAsset.isExpanded = self.assets.first(where: {$0 == newAsset})?.isExpanded ?? false
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
    
    func toggleAssetExpanded(asset: AssetSummary, section: Int) {
        if let index = assetsSummary.firstIndex(where: {$0 == asset}) {
            assetsSummary[index].isExpanded.toggle()
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
    
    func getAssets() -> [AssetSummary] {
        assetsSummary.filter({$0.asset != nil}).sorted(by: {$0.asset!.name < $1.asset!.name})
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
