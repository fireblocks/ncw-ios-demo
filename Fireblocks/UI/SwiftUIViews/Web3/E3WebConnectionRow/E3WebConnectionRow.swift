//
//  E3WebConnectionRow.swift
//  EW-dev
//
//  Created by Dudi Shani-Gabay on 24/02/2025.
//

import SwiftUI
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

struct E3WebConnectionRow: View {
    @State var viewModel: ViewModel
    
    init(connection: Web3Connection) {
        _viewModel = State(initialValue: ViewModel(connection: connection))

    }
    
    var body: some View {
        HStack(spacing: 16) {
            if let image = viewModel.image {
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .clipShape(.rect(cornerRadius: 8))
            } else {
                Text("DAPP")
                    .placeholderHeader()
            }
            VStack(spacing: 8) {
                if let appName = viewModel.connection.sessionMetadata?.appName {
                    Text(appName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.b1)
                }
                if let appDescription = viewModel.connection.sessionMetadata?.appDescription {
                    Text(appDescription)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.secondary)
                        .font(.b4)
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .animation(.default, value: viewModel.image)
    }
}

#Preview {
    E3WebConnectionRow(connection: EWManagerMock().getItem(type: Web3Connection.self, item: Mocks.Connections.connection)!)
}
