//
//  AssetListViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 15/06/2023.
//

import Foundation
import FirebaseAuth
import Combine
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

class AssetsSequence: AsyncSequence {
    let assets: [Asset]

    init(assets: [Asset]) {
        self.assets = assets
    }
    
    struct AsyncIterator : AsyncIteratorProtocol {
        let assets: [Asset]
        private var currentIndex = 0
        
        init(assets: [Asset], currentIndex: Int = 0) {
            self.assets = assets
            self.currentIndex = currentIndex
        }
        
        mutating func next() async -> Asset? {
            guard !Task.isCancelled else {
                return nil
            }
            
            if currentIndex >= assets.count {
                return nil
            }
            
            let result = assets[currentIndex]
            currentIndex += 1
            return result
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(assets: assets)
    }

    typealias Element = Asset
}

@Observable
class AssetListViewModel: AssetListViewModelBase {
    var ewManager: EWManager?
    static let shared = AssetListViewModel()
    
    func setup(ewManager: EWManager, loadingManager: LoadingManager, coordinator: Coordinator) {
        if !didLoad {
            didLoad = true
            self.ewManager = ewManager
            self.loadingManager = loadingManager
            self.coordinator = coordinator
            self.loadingManager?.isLoading = true
            
            fetchAssets()
        }
        
    }
    
    
    func listenToTransferChanges() {
//        TransfersViewModel.shared.$transfers.receive(on: RunLoop.main)
//            .sink { [weak self] transfers in
//                if let self {
//                    self.task?.cancel()
//                    self.fetchAssets()
//                }
//            }.store(in: &cancellable)
    }

    override func fetchAssets() {
        Task {
            do {
                let assets = try await ewManager?.fetchAllAccountAssets(accountId: accountId)
                if let assets, assets.count > 0 {
                    let assetsSequence = AssetsSequence(assets: assets)
                    for try await asset in assetsSequence {
                        await withTaskGroup(of: (AssetBalance?, [AddressDetails]).self) { [weak self] group in
                            guard let self else { return }
                            group.addTask{
                                let balance = await self.getAssetBalance(asset: asset)
                                let addresses = await self.getAddresses(asset: asset)
                                if let index = self.assetsSummary.firstIndex(where: {$0.asset == asset}) {
                                    self.assetsSummary[index].asset = asset
                                    self.assetsSummary[index].address = addresses.first
                                    self.assetsSummary[index].balance = balance
                                } else {
                                    self.assetsSummary.append(AssetSummary(asset: asset, address: addresses.first, balance: balance))
                                }
                                await self.loadingManager?.setLoading(value: false)
                                return (balance, addresses)
                            }
                        }
                    }
                }
            } catch {
                await self.loadingManager?.setAlertMessage(error: error)
            }
            await self.loadingManager?.setLoading(value: false)

        }
    }
    
    private func getAssetBalance(asset: Asset) async -> AssetBalance? {
        guard let assetId = asset.id else {
            return nil
        }
        do {
            return try await ewManager?.getAssetBalance(assetId: assetId, accountId: accountId)
        } catch {
            await self.loadingManager?.setAlertMessage(error: error)
            return nil
        }

    }
    
    private func getAddresses(asset: Asset) async -> [AddressDetails] {
        guard let assetId = asset.id else {
            return []
        }
        
        guard let _ = Auth.auth().currentUser?.email else {
            return []
        }

        if let addresses = UsersLocalStorageManager.shared.getAddressDetails(accountId: accountId, assetId: assetId) {
            return addresses
        }

        do {
            if let addresses = try await ewManager?.fetchAllAccountAssetAddresses(assetId: assetId, accountId: accountId) {
                UsersLocalStorageManager.shared.setAddressDetails(accountId: accountId, assetId: assetId, addressDetails: addresses)
                return addresses
            }
        } catch {
            await self.loadingManager?.setAlertMessage(error: error)
        }
        return []

    }

    override func getBalance() -> String {
        var balanceSum: Double = 0.0
        assetsSummary.filter({$0.balance != nil}).forEach { assetSummary in
            if let assetId = assetSummary.asset?.id, let total = assetSummary.balance?.total, let price = Double(total) {
                balanceSum += CryptoCurrencyManager.shared.getPrice(assetId: assetId, networkProtocol: assetSummary.asset?.networkProtocol, amount: price)
            }
        }
        
        let balanceSumString = balanceSum.formatFractionsAsString(fractionDigits: 2)
        return balanceSumString
    }
        
}
