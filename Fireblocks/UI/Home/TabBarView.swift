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
        case .NFTs:
            return "NFTs"
        case .Web3:
            return "Web3"
        }
    }
    
    var navigationTitle: String {
        switch self {
        case .Assets:
            return "Assets"
        case .Transfers:
            return "Transfers"
        case .NFTs:
            return "NFTs"
        case .Web3:
            return "WeWeb3 connectionsb3"
        }
    }

}

struct TabBarView: View {
    @EnvironmentObject var coordinator: Coordinator

    @State var selectedIndex = TabIndex.Assets

    var body: some View {
        VStack(spacing: 0) {
            switch selectedIndex {
            case .Assets:
                AssetListView()
            case .Transfers:
                GenericController(uiViewType: TransfersViewController())
#if EW
            case .NFTs:
                EWNFTsView()
            case .Web3:
                EWWeb3ConnectionsView(accountId: 0)
#endif
            }
        }
        .safeAreaPadding(0)
        .safeAreaInset(edge: .bottom, content: {
            HStack(spacing: 8) {
                ForEach(TabIndex.allCases, id: \.self) { index in
                    getTabItem(tag: index.rawValue, title: index.title)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical)
            .background(AssetsColors.gray1.color())
        })
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
    func getTabItem(tag: Int, title: String) -> some View {
        Text(title)
            .font(.caption)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(tag == selectedIndex.rawValue ? AnyShapeStyle(AssetsColors.gray2.color()) : AnyShapeStyle(Color.clear))
            .clipShape(.rect(cornerRadius: 8))
            .contentShape(.rect)
            .onTapGesture {
                selectedIndex = TabIndex(rawValue: tag) ?? .Assets
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
