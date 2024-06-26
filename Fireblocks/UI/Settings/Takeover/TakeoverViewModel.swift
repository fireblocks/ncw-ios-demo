//
//  TakeoverViewModel.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 19/07/2023.
//

import Foundation
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

protocol TakeoverViewModelDelegate: AnyObject {
    func didReceiveFullKeys(fullKeys: Set<FullKey>?)
}

final class TakeoverViewModel  {
    weak var delegate: TakeoverViewModelDelegate?
    
    func getTakeoverFullKeys() {
        Task {
            let keys = await FireblocksManager.shared.takeOver()
            delegate?.didReceiveFullKeys(fullKeys: keys)
        }

    }
}
