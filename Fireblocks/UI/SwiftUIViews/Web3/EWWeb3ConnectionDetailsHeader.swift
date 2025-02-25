//
//  EWWeb3ConnectionDetailsHeader.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 25/02/2025.
//
import SwiftUI
import EmbeddedWalletSDKDev

struct EWWeb3ConnectionDetailsHeader: View {
    let metadata: Web3ConnectionSessionMetadata?
    let isConnected: Bool
    @State var image: Image?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 36)
                
                VStack(spacing: 24) {
                    if let appName = metadata?.appName {
                        HStack(spacing: 8) {
                            Spacer()
                            Text("Connect to \(appName)")
                                .font(.h4)
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 24)
                            if isConnected {
                                Image(.success)
                            }
                            Spacer()
                        }
                        .padding()
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
        .onAppear {
            if let imageURL = metadata?.appIcon, let url = URL(string: imageURL) {
                Task {
                    if let data = try? Data(contentsOf: url) {
                        if let uiimage = UIImage(data: data) {
                            await MainActor.run {
                                self.image = Image(uiImage: uiimage)
                            }
                        }
                    }
                }
            }

        }
    }
}

#Preview("isConnected false") {
    NavigationContainerView(isPreview: true) {
        SpinnerViewContainer {
            EWWeb3ConnectionDetailsHeader(metadata: EWManagerMock().getItem(type: Web3Connection.self, item: Mocks.Connections.connection)!.sessionMetadata, isConnected: false)
        }
    }
}

#Preview("isConnected true") {
    NavigationContainerView(isPreview: true) {
        SpinnerViewContainer {
            EWWeb3ConnectionDetailsHeader(metadata: EWManagerMock().getItem(type: Web3Connection.self, item: Mocks.Connections.connection)!.sessionMetadata, isConnected: true)
        }
    }
}


