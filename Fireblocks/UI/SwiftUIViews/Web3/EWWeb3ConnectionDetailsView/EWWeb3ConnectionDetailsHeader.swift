//
//  EWWeb3ConnectionDetailsHeader.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 25/02/2025.
//
import SwiftUI
import EmbeddedWalletSDKDev

struct EWWeb3ConnectionDetailsHeader: View {
    @Environment(EWManager.self) var ewManager
    var connection: Web3Connection?
    let metadata: Web3ConnectionSessionMetadata?
    let isConnected: Bool
    @State var image: Image?
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 36)
                    
                    VStack(spacing: 24) {
                        if let appName = metadata?.appName {
                            HStack(spacing: 8) {
                                Spacer()
                                Text("\(appName.capitalized) Connection")
                                    .font(.h4)
                                    .multilineTextAlignment(.center)
                                if isConnected {
                                    Image(.success)
                                }
                                Spacer()
                            }
                        }
                        
                        if let creationDate = connection?.creationDate, let date = creationDate.iso8601Date() {
                            HStack(spacing: 8) {
                                Text("Connection date")
                                    .font(.b2)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                Text(date)
                                    .font(.b2)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }

                        if let blockchains = connection?.chainIds {
                            VStack(spacing: 8) {
                                Text("Blockchains")
                                    .font(.b2)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(blockchains, id: \.self) { chain in
                                            Text(chain)
                                                .font(.b2)
                                                .foregroundStyle(.secondary)
                                                .padding(6)
                                                .background(AssetsColors.gray2.color(), in: .capsule)
                                        }
                                    }
                                }
                            }
                        }

                        if let feeLevel = connection?.feeLevel?.rawValue {
                            HStack(spacing: 8) {
                                Text("Fee Level")
                                    .font(.b2)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                Text(feeLevel)
                                    .font(.b2)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        
                        if let connectionId = connection?.id {
                            VStack(spacing: 8) {
                                Text("Id")
                                    .font(.b2)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack {
                                    Text(connectionId)
                                        .font(.b2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                    
                                    Button {
                                        ewManager.errorMessage = "Copied!"
                                        UIPasteboard.general.string = connectionId
                                    } label: {
                                        Image(uiImage: AssetsIcons.copy.getIcon())
                                    }
                                    .tint(.white)

                                }
                            }
                        }


                        if let description = metadata?.appDescription {
                            VStack(spacing: 8) {
                                Text("Description")
                                    .font(.b2)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(description)
                                    .font(.b2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        if let appUrl = metadata?.appUrl {
                            VStack(spacing: 8) {
                                Text("Website")
                                    .font(.b2)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(appUrl)
                                    .font(.b2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        if !isConnected {
                            Text("Note that if you authorize a 3rd party to access your wallet it may be risky or something....")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .font(.b4)
                        }
                    }
                    .padding()
                    .padding(.top, 36)
                    .background(AssetsColors.gray1.color(), in: .rect(cornerRadius: 16))
                    
                    Spacer()
                }
                
                VStack {
                    Group {
                        if let image {
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 72, height: 72)
                                .clipShape(.rect(cornerRadius: 8))
                        } else {
                            Text("DAPP")
                                .placeholderHeader()
                        }
                    }
                    Spacer()
                    
                }
                
            }
        }
        .onAppear {
            if let imageURL = metadata?.appIcon, let url = URL(string: imageURL) {
                Task {
                    let uiimage = try await SessionManager.shared.loadImage(url: url)
                    await MainActor.run {
                        self.image = Image(uiImage: uiimage)
                    }
                }
            }

        }
    }
}

#Preview("isConnected false") {
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            EWWeb3ConnectionDetailsHeader(connection: EWManagerMock().getItem(type: Web3Connection.self, item: Mocks.Connections.connection)!, metadata: EWManagerMock().getItem(type: Web3Connection.self, item: Mocks.Connections.connection)!.sessionMetadata, isConnected: false)
                .environment(EWManager())
        }
    }
}

#Preview("isConnected true") {
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            EWWeb3ConnectionDetailsHeader(connection: EWManagerMock().getItem(type: Web3Connection.self, item: Mocks.Connections.connection)!, metadata: EWManagerMock().getItem(type: Web3Connection.self, item: Mocks.Connections.connection)!.sessionMetadata, isConnected: true)
                .environment(EWManager())
        }
    }
}


