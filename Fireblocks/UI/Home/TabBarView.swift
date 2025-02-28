//
//  TabBarView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 11/02/2025.
//

import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var coordinator: Coordinator

    @State var selectedIndex = 0
    #if EW
    let tabs = ["Assets", "Transfers", "NFTs", "Web3"]
    #else
    let tabs = ["Assets", "Transfers"]
    #endif

    var body: some View {
        TabView(selection: $selectedIndex) {
            GenericController(uiViewType: AssetListViewController())
                .tabItem {
                    getTabItem(tag: 0, title: "Assets")
                }
                .tag(0)
            GenericController(uiViewType: TransfersViewController())
                .tabItem {
                    getTabItem(tag: 1, title: "Transfers")
                }
                .tag(1)
            #if EW
            EWNFTsView()
            .tabItem {
                getTabItem(tag: 2, title: "NFTs")
            }
            .tag(2)
            EWWeb3ConnectionsView(accountId: 0)
            .tabItem {
                getTabItem(tag: 3, title: "Web3")
            }
            .tag(3)
            #endif
        }
        .safeAreaInset(edge: .bottom, content: {
            HStack(spacing: 8) {
                ForEach(tabs.indices) { index in
                    getTabItem(tag: index, title: tabs[index])
                }
            }
            .frame(height: 64)
            .padding(.horizontal, 8)
            .background(Color.black)
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
        .navigationTitle(getHeader(tag: selectedIndex))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func getHeader(tag: Int) -> String {
        switch tag {
        case 0:
            return "Assets"
        case 1:
            return "Transfers"
        case 2:
            return "NFTs"
        case 3:
            return "Web3 connections"
        default:
            return ""
        }
    }
    
    @ViewBuilder
    func getTabItem(tag: Int, title: String) -> some View {
        Text(title)
            .font(.caption)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(tag == selectedIndex ? AnyShapeStyle(.thinMaterial) : AnyShapeStyle(Color.clear))
            .clipShape(.rect(cornerRadius: 8))
            .contentShape(.rect)
            .onTapGesture {
                selectedIndex = tag
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
