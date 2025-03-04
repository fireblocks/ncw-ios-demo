//
//  TransactionStatusView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 03/03/2025.
//

import SwiftUI

struct TransactionStatusView: View {
    let transferInfo: TransferInfo
    var body: some View {
        Text(transferInfo.status.rawValue)
            .font(.b4)
            .foregroundStyle(transferInfo.getColor())
    }
}

//#Preview {
//    TransactionStatusView(transferInfo: Tran)
//}
