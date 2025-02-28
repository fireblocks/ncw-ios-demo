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
class AssetListViewModel {
    var ewManager: EWManager!
    var loadingManager: LoadingManager!
    var coordinator: Coordinator!
    var didLoad = false
    var addAssetPresented = false
    
    weak var delegate: AssetListViewModelDelegate?
    var assetsSummary: [AssetSummary] = []
    private var task: Task<Void, Never>?
    var cancellable = Set<AnyCancellable>()
    var chooseAssetFlowType: ChooseAssetFlowType = .send
    let accountId = 0
    static let shared = AssetListViewModel()

    private init() {}
    
    func setup(ewManager: EWManager, loadingManager: LoadingManager, coordinator: Coordinator) {
        if !didLoad {
            didLoad = true
            self.ewManager = ewManager
            self.loadingManager = loadingManager
            self.coordinator = coordinator
            self.loadingManager?.isLoading = true
        }
        
        fetchAssets()
    }
    
    func signOut() {
        assetsSummary.removeAll()
        cancellable.removeAll()
    }
    
    deinit {
        task?.cancel()
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

    func fetchAssets() {
        Task {
            let assets = await ewManager?.fetchAllAccountAssets(accountId: accountId)
            if let assets, assets.count > 0 {
                let assetsSequence = AssetsSequence(assets: assets)
                for try await asset in assetsSequence {
                    await withTaskGroup(of: (EmbeddedWalletSDKDev.AssetBalance?, [EmbeddedWalletSDKDev.AddressDetails]).self) { [weak self] group in
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
                            return (balance, addresses)
                        }
                    }
                }
                await self.loadingManager?.setLoading(value: false)
            } else {
                await self.loadingManager?.setLoading(value: false)
            }
        }
    }
    
//    func loadAssetData() async {
//        await withTaskGroup(of: (EmbeddedWalletSDKDev.AssetBalance?, [EmbeddedWalletSDKDev.AssetAddress]).self) { group in
//            group.addTask{
//                self.balance = await self.getAssetBalance()
//                self.addresses = await self.getAddresses()
//                return (self.balance, self.addresses)
//            }
//        }
//    }
    
    private func getAssetBalance(asset: Asset) async -> EmbeddedWalletSDKDev.AssetBalance? {
        guard let assetId = asset.id else {
            return nil
        }
        return await ewManager.getAssetBalance(assetId: assetId, accountId: accountId)

    }
    
    private func getAddresses(asset: Asset) async -> [EmbeddedWalletSDKDev.AddressDetails] {
        guard let assetId = asset.id else {
            return []
        }
        
        guard let _ = Auth.auth().currentUser?.email else {
            return []
        }

        if let addresses = UsersLocalStorageManager.shared.getAddressDetails(accountId: accountId, assetId: assetId) {
            return addresses
        }

        let addresses = await ewManager.fetchAllAccountAssetAddresses(assetId: assetId, accountId: accountId)
        UsersLocalStorageManager.shared.setAddressDetails(accountId: accountId, assetId: assetId, addressDetails: addresses)
        return addresses

    }

    func toggleAssetExpanded(asset: AssetSummary, section: Int = 0) {
        if let index = assetsSummary.firstIndex(where: {$0 == asset}) {
            assetsSummary[index].isExpanded.toggle()
        }
    }
    
    func getAssetSummary() -> [AssetSummary] {
        return assetsSummary
    }
    
    func getAssets() -> [AssetSummary] {
        return assetsSummary
    }
    
    func getAssetsCount() -> Int {
        assetsSummary.count
    }
    
    func getBalance() -> String {
        var balanceSum: Double = 0.0
        assetsSummary.filter({$0.balance != nil}).map({$0.balance!}).forEach { balance in
            if let assetId = balance.id, let total = balance.total, let price = Double(total) {
                balanceSum += CryptoCurrencyManager.shared.getPrice(assetId: assetId, amount: price)
            }
        }
        
        return "$\(balanceSum.formatFractions(fractionDigits: 2))"
    }
    
    func getIsButtonsEnabled() -> Bool {
        return !assetsSummary.isEmpty
    }
    
    func getAsset(by assetId: String) -> Asset? {
        return assetsSummary.filter({$0.asset != nil}).map({$0.asset!}).first(where: {$0.id == assetId})
    }
    
    func didTapSend(index: Int) {
        if assetsSummary.count > index {
            let asset = getAssets()[index]
            self.chooseAssetFlowType = .send
            delegate?.navigateToNextScreen(with: asset)
        }
    }
    
    func didTapReceive(index: Int) {
        if assetsSummary.count > index {
            let asset = getAssets()[index]
            self.chooseAssetFlowType = .receive
            delegate?.navigateToNextScreen(with: asset)
        }
    }

    
}

extension AssetListViewModel: AddAssetsViewControllerDelegate {
    func dismissAddAssets(addedAssets: [Asset], failedAssets: [Asset]) {
        self.addAssetPresented = false
        if failedAssets.count > 0 {
//            let prefix = failedAssets.count > 1 ? "The following assets were" : "The following asset was"
//            var assets: String = ""
//            failedAssets.forEach { asset in
//                assets += " \(asset.symbol),"
//            }
//            assets.removeLast()
//            self.showAlertView(message: "\(prefix) not added: \(assets).\nPlease try again\n")
        }
        if addedAssets.count > 0 {
            loadingManager.isLoading = true
            fetchAssets()
        }
    }
}

