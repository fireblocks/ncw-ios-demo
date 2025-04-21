//
//  AdvancedInfoView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 21/04/2025.
//

import SwiftUI
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

extension AdvancedInfoView {
    
    @Observable
    class ViewModel {
        var fireblocksManager: FireblocksManager?
        var mpcKeys: [KeyDescriptor] = []
        var walletId = ""
        var deviceId = ""
        
        func setup(fireblocksManager: FireblocksManager) {
            self.fireblocksManager = fireblocksManager
            do {
                self.mpcKeys = try fireblocksManager.getMpcKeys()
            } catch {
                self.mpcKeys = []
            }
            self.walletId = fireblocksManager.getWalletId()
            self.deviceId = fireblocksManager.getDeviceId()
        }
        
    }

}

struct AdvancedInfoView: View {
    @EnvironmentObject var fireblocksManager: FireblocksManager
    @State var viewModel = ViewModel()

    var body: some View {
        ZStack {
            AppBackgroundView()
            List {
                VStack(spacing: 0) {
                    let views: [AnyView] = [
                        AnyView(walletId),
                        AnyView(deviceId),
                        AnyView(mpcKeys)

                    ]
                    
                    VStack(spacing: 0) {
                        ForEach(0..<views.count, id: \.self) { index in
                            views[index]
                            if index < views.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

            }
            .scrollContentBackground(.hidden)
        }
        .onAppear() {
            viewModel.setup(fireblocksManager: fireblocksManager)
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                CustomBackButtonView()
            }
        })
        .navigationTitle(LocalizableStrings.advancedInfo)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .contentMargins(.top, 16)

    }
    
    @ViewBuilder
    private var walletId: some View {
        DetailsListItemView(
            title: LocalizableStrings.walletId,
            contentText: viewModel.walletId,
            showCopyButton: true
        )
    }

    @ViewBuilder
    private var deviceId: some View {
        DetailsListItemView(
            title: LocalizableStrings.deviceId,
            contentText: viewModel.deviceId,
            showCopyButton: true
        )
    }

    @ViewBuilder
    private var mpcKeys: some View {
        ForEach(viewModel.mpcKeys) { keyDescriptor in
            DetailsListItemView(
                title: LocalizableStrings.keyId,
                contentText: keyDescriptor.keyId,
                showCopyButton: false
            )
            DetailsListItemView(
                title: LocalizableStrings.algorithm,
                contentText: keyDescriptor.algorithm?.rawValue,
                showCopyButton: false
            )
        }
    }

}

#Preview {
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            AdvancedInfoView()
        }
    }
}
