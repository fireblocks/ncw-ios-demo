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
    var ewManager = EWManager.shared
    @Published var response: TransactionResponse?
    
    func startPolling(txId: String) async {
        if self.txId != nil { return }
        self.txId = txId
        await pollTransaction(txId: txId)
    }
    
    func stopPolling() {
        self.txId = nil
    }
    
    func pollTransaction(txId: String, poll: Bool = true) async {
        if self.txId == nil { return }
        self.response = await ewManager.getTransactionById(txId: txId)
        
        if poll {
            do {
                try await Task.sleep(nanoseconds: 1 * 3_000_000_000)
                await pollTransaction(txId: txId, poll: poll)
            } catch {
                print(error.localizedDescription)
            }
        }

    }
}
