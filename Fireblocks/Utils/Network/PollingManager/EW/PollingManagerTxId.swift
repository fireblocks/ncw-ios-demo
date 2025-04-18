//
//  PollingManagerTxId.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/01/2025.
//

#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif


class PollingManagerTxId: ObservableObject {
    var txId: String?
    var ewManager: EWManager
    @Published var response: TransactionResponse?
    
    init(ewManager: EWManager) {
        self.ewManager = ewManager
    }
    
    func startPolling(txId: String) {
        if self.txId != nil { return }
        self.txId = txId
        Task {
            await pollTransaction(txId: txId)
        }
    }
    
    func stopPolling() {
        self.txId = nil
    }
    
    func pollTransaction(txId: String, poll: Bool = true) async {
        if self.txId == nil { return }
        self.response = try? await ewManager.getTransactionById(txId: txId)
        
        if poll {
            do {
                try await Task.sleep(for: .seconds(3))
                await pollTransaction(txId: txId, poll: poll)
            } catch {
                print(error.localizedDescription)
            }
        }

    }
}
