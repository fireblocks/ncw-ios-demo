//
//  AssetListViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 15/06/2023.
//

import Foundation
import Combine

@Observable
class AssetListViewModel: AssetListViewModelBase {
    private let repository = AssetListRepository()
    static let shared = AssetListViewModel()
    
    func setup(loadingManager: LoadingManager, coordinator: Coordinator) {
        if !didLoad {
            didLoad = true
            self.loadingManager = loadingManager
            self.coordinator = coordinator
            self.loadingManager?.isLoading = true
            
            fetchAssets()
        }
        
    }

    func listenToTransferChanges() {
//        TransfersViewModel.shared.$transfers.receive(on: RunLoop.main)
//            .sink { [weak self] (transfers: [TransferInfo]) in
//                if let self {
//                    self.task?.cancel()
//                    self.fetchAssets()
//                }
//            }.store(in: &cancellable)
    }

    override func fetchAssets() {
        task = Task {
            do {
                let assetResponse = try await repository.getAssets()
                var tempSummary = assetResponse.map({$0.value})
                for index in 0..<tempSummary.count {
                    tempSummary[index].isExpanded = self.assetsSummary.first(where: {$0 == tempSummary[index]})?.isExpanded ?? false
                }
                let summary = tempSummary

                await MainActor.run {
                    self.assetsSummary = summary
                    self.loadingManager?.isLoading = false
                }
            } catch URLError.cancelled {
                print("URLError.cancelled")
            } catch let error as NSError {
                if Task.isCancelled {
                    print(error.localizedDescription)
                } else {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func getBalance() -> String {
        var balanceSum: Double = 0.0
        assetsSummary.filter({$0.asset != nil}).map({$0.asset!}).forEach { asset in
            if let price = asset.price {
                balanceSum += price 
            }
        }
        
        return "$\(balanceSum.formatFractions())"
    }
    
}
