//
//  AdvancedInfoView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import SwiftUI

struct AdvancedInfoView: View {
    @EnvironmentObject var bannerErrorsManager: BannerErrorsManager

    @StateObject var viewModel = ViewModel()
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Group {
                    AdvancedInfoDetailsView(header: "Wallet ID", details: viewModel.getWalletId())
                    AdvancedInfoDetailsView(header: "Device ID", details: viewModel.getDeviceId())
                }
                .environmentObject(bannerErrorsManager)

                Divider()
                
                ForEach(viewModel.getMpcKeys()) { key in
                    KeyDescriptorDetailsView(key: key)
                }
                
                Spacer()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    path.removeLast()
                } label: {
                    Image(uiImage: AssetsIcons.back.getIcon())
                }
                .tint(.primary)
            }
        }
        .toast(item: bannerErrorsManager.toastMessage)
        .navigationTitle("Advanced Info")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()

    }
}

#Preview {
    AdvancedInfoView(path: .constant(NavigationPath()))
}
