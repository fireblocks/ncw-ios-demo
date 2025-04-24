//
//  TabBarView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 11/02/2025.
//

import SwiftUI

enum TabIndex: Int, CaseIterable {
    case Assets = 0
    case Transfers = 1
#if EW
    case NFTs = 2
    case Web3 = 3
#endif
    
    var title: String {
        switch self {
        case .Assets:
            return "Assets"
        case .Transfers:
            return "Transfers"
        #if EW
        case .NFTs:
            return "NFTs"
        case .Web3:
            return "Web3"
        #endif
        }
    }
    
    var navigationTitle: String {
        switch self {
        case .Assets:
            return "Assets"
        case .Transfers:
            return "Transfers"
        #if EW
        case .NFTs:
            return "NFTs"
        case .Web3:
            return "Web3 Connections"
        #endif
        }
    }
    
}

struct TabBarView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var fireblocksManager: FireblocksManager

    @State var selectedIndex = TabIndex.Assets
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedIndex) {
                SpinnerViewContainer(title: "Loading wallet...") {
                    AssetListView()
                }
                .tabItem {
                    getTabItem(.Assets)
                }
                .tag(TabIndex.Assets)
                
                SpinnerViewContainer {
                    TransferListView()
//                    GenericController(uiViewType: TransfersViewController())
                }
                .tabItem {
                    getTabItem(.Transfers)
                }
                .tag(TabIndex.Transfers)
                
#if EW
                SpinnerViewContainer {
                    EWNFTsView()
                }
                .tabItem {
                    getTabItem(.NFTs)
                }
                .tag(TabIndex.NFTs)
                
                SpinnerViewContainer {
                    EWWeb3ConnectionsView(accountId: 0)
                }
                .tabItem {
                    getTabItem(.Web3)
                }
                .tag(TabIndex.Web3)
                
#endif
            }
            
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(TabIndex.allCases, id: \.self) { index in
                        getTabItem(index)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .background(Color(.background))
            }
        }
        .animation(.default, value: selectedIndex)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.path.append(NavigationTypes.settings)
                } label: {
                    Image(.settings)
                }
                .tint(.white)
            }
        }
        .navigationTitle(selectedIndex.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    @ViewBuilder
    func getTabItem(_ tabIndex: TabIndex) -> some View {
        Text(tabIndex.title)
            .font(.caption)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .background(tabIndex == selectedIndex ? AnyShapeStyle(AssetsColors.gray2.color()) : AnyShapeStyle(Color.clear))
            .clipShape(.rect(cornerRadius: 8))
            .contentShape(.rect)
            .onTapGesture {
                selectedIndex = tabIndex
            }
    }
    
}

//#Preview {
//    NavigationContainerView(mockManager: EWManagerMock()) {
//        SpinnerViewContainer {
//            TabBarView()
//        }
//    }
//}
