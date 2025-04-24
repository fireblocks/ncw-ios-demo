//
//  EWWeb3ConnectionDetailsHeader.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 25/02/2025.
//
import SwiftUI
#if DEV
import EmbeddedWalletSDKDev
#else
import EmbeddedWalletSDK
#endif

struct EWWeb3ConnectionDetailsHeader: View {
    @Environment(EWManager.self) var ewManager
    @Environment(LoadingManager.self) var loadingManager
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
                    
                    VStack(spacing: 0) {
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
                            .padding(.top, 12)
                            Divider()
                                .padding(.top, 47)
                        }
                        
                        if let description = metadata?.appDescription {
                            DetailsListItemView(
                                title: LocalizableStrings.description,
                                contentText: description
                            )
                            Divider()
                        }
                        
                        if let appUrl = metadata?.appUrl {
                            DetailsListItemView( //TODO: make this a link
                                title: "URL",
                                contentText: appUrl
                            )
                            Divider()
                        }
                        
                        if let creationDate = connection?.creationDate, let date = creationDate.iso8601Date() {
                            DetailsListItemView(
                                title: "Connection date",
                                contentText: creationDate
                            )
                            Divider()
                        }

                        if let blockchains = connection?.chainIds {
                            SupportedBlockchainsListItemView(chainIds: blockchains)
                            Divider()
                        }
                        
                        if let connectionId = connection?.id {
                            DetailsListItemView(
                                title: "Fireblocks connection ID",
                                contentText: connectionId
                            )
                            Divider()
                        }
                        
                    }
                    .padding(.top, 36)
                    .background(AssetsColors.gray1.color(), in: .rect(cornerRadius: 16))
                    
                    Spacer()
                }
                
                VStack {
                    Group {
                        if let image {
                            image.resizable()
                                .padding(8)
                        } else {
                            Image(.dappPlaceholder)
                        }
                    }
                    .frame(width: 72, height: 72)
                    .background(Color.white)
                    .clipShape(.rect(cornerRadius: 8))
                    .contentShape(Rectangle())
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


