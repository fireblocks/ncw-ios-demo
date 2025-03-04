//
//  PollingManager.swift
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

class PollingManager: ObservableObject {
    let completedTransactionStatus: [Status] = [.completed, .failed, .cancelled]
    let ewManager = EWManager.shared
    var isActive: Bool = false
    var afterTimestamp: Int?
    @Published var transactions: [TransactionResponse] = []
    var incomingTransactions: [TransactionResponse] = []
    var outgoingTransactions: [TransactionResponse] = []
    
    static let shared = PollingManager()
    private init() {}
    
    func startPolling(accountId: Int, order: Order) async {
        guard !isActive else { return }
        isActive = true
        await pollTransactions(accountId: accountId, order: order)
    }
    
    func stopPolling() {
        isActive = false
        afterTimestamp = nil
        transactions.removeAll()
        incomingTransactions.removeAll()
        outgoingTransactions.removeAll()
    }
    
    func fetchTransactions(accountId: Int, order: Order) async {
        await pollTransactions(accountId: accountId, poll: false, order: order)
    }

    private func pollTransactions(accountId: Int, poll: Bool = true, order: Order) async {
        if !isActive { return }
        afterTimestamp = self.transactions.filter({$0.createdAt != nil && $0.status != nil && !completedTransactionStatus.contains($0.status!)}).sorted(by: {$0.createdAt! < $1.createdAt!}).first?.createdAt
        if afterTimestamp == nil {
            if let max = self.transactions.filter({$0.createdAt != nil}).sorted(by: {$0.createdAt! > $1.createdAt!}).first?.createdAt {
                afterTimestamp = max + 1
            }
        }
        let after = afterTimestamp != nil ? String(afterTimestamp!) : nil
        await withTaskGroup(of: ([TransactionResponse], [TransactionResponse]).self) { group in
            group.addTask{
                let incoming = try? await self.ewManager.getTransactions( after: after, pageCursor: nil, order: order, incoming: true, destId: "\(accountId)")
                let outgoing = try? await self.ewManager.getTransactions(after: after, pageCursor: nil, order: order, sourceId: "\(accountId)", outgoing: true)
                self.updateTransactions(incoming: true, data: incoming?.data ?? [])
                self.updateTransactions(incoming: false, data: outgoing?.data ?? [])
                return (self.incomingTransactions, self.outgoingTransactions)
            }
        }

        self.transactions = (self.incomingTransactions + self.outgoingTransactions).filter({$0.createdAt != nil}).sorted(by: {$0.createdAt! > $1.createdAt!})

        if poll {
            do {
                try await Task.sleep(nanoseconds: 1 * 5_000_000_000)
                await pollTransactions(accountId: accountId, poll: poll, order: order)
            } catch {
                print(error.localizedDescription)
            }
        }

    }
    
    private func updateTransactions(incoming: Bool, data: [TransactionResponse]) {
        if incoming {
            print("INCOMING COUNT: \(data.count)")
            data.forEach { transaction in
                if let exist = incomingTransactions.filter({ $0.id == transaction.id }).first {
                    if exist.lastUpdated != transaction.lastUpdated {
                        incomingTransactions.removeAll(where: {$0.id == transaction.id})
                        incomingTransactions.append(transaction)
                    }
                } else {
                    incomingTransactions.append(transaction)
                }
            }
        } else {
            print("OUTGOING COUNT: \(data.count)")
            data.forEach { transaction in
                if let exist = outgoingTransactions.filter({ $0.id == transaction.id }).first {
                    if exist.lastUpdated != transaction.lastUpdated {
                        outgoingTransactions.removeAll(where: {$0.id == transaction.id})
                        outgoingTransactions.append(transaction)
                    }
                } else {
                    outgoingTransactions.append(transaction)
                }
            }
        }
    }

}
