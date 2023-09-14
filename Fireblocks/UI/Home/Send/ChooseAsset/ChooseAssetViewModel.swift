//
//  ChooseAssetViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 20/06/2023.
//

import Foundation

protocol ChooseAssetViewModelDelegate: AnyObject {
    func navigateToNextScreen(asset: Asset)
}

enum ChooseAssetFlowType {
    case send
    case receive
}

class ChooseAssetViewModel {
    
    var assets: [Asset] = []
    var chooseAssetFlowType: ChooseAssetFlowType = .send
    private let repository = ChooseAssetRepository()
    private var task: Task<Void, Never>?
    weak var delegate: ChooseAssetViewModelDelegate?
    
    deinit {
        task?.cancel()
    }
    
    func getAssetFor(index: Int) -> Asset {
        assets[index]
    }
    
    func getAssets() -> [Asset] {
        assets
    }
    
    func getAssetsCount() -> Int {
        assets.count
    }
    
    func getdataForNextScreen(index: Int) {
        
        task = Task {
            do {
                var asset = assets[index]
                if asset.address == nil {
                    asset.address = try await repository.getAddress(for: asset.id)
                }
                delegate?.navigateToNextScreen(asset: asset)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
