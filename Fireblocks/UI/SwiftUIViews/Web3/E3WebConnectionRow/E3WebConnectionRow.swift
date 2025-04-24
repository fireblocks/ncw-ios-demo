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
            HStack(spacing: 0) {
                image
            }
            .frame(width: 64, height: 64)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 8))
            .contentShape(Rectangle())
            
            VStack(spacing: 8) {
                if let appName = viewModel.connection.sessionMetadata?.appName {
                    Text(appName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.b1)
                }
                if let creationDate = viewModel.connection.creationDate, let date = creationDate.iso8601Date() {
                    Text("Connected on: \(date)")
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
    
    @ViewBuilder
    private var image: some View {
        if let image = viewModel.image {
            image.resizable()
                .padding(8)
        } else {
            Image(.dappPlaceholder)
        }
    }
}

#Preview {
    E3WebConnectionRow(connection: EWManagerMock().getItem(type: Web3Connection.self, item: Mocks.Connections.connection)!)
}
