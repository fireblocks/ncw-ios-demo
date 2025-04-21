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
                Section {
                    VStack(spacing: 0) {
                        deviceId
                        Divider()
                        walletId
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                mpcKeys                
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
            let keyStatus = keyDescriptor.keyStatus
            
            Section {
                VStack(spacing: 0) {
                    DetailsListItemView(
                        attributedTitle: attributedKeyIdWithStatus(
                            keyId: LocalizableStrings.keyId,
                            keyStatus: keyStatus
                        ),
                        contentText: keyDescriptor.keyId,
                        showCopyButton: true
                    )
                    
                    Divider()
                    
                    DetailsListItemView(
                        title: LocalizableStrings.algorithm,
                        contentText: keyDescriptor.algorithm?.rawValue,
                        showCopyButton: false
                    )
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
    }
    
}

private func attributedKeyIdWithStatus(keyId: String, keyStatus: KeyStatus?) -> AttributedString {
    var result = AttributedString(keyId)
    result.font = .b2
    result.foregroundColor = .secondary
    result.append(AttributedString("\n"))
    
    if let keyStatus = keyStatus {
        var statusText = AttributedString(keyStatus.rawValue.capitalizeFirstCharOnly())
        statusText.foregroundColor = getStatusColor(keyStatus: keyStatus)
        statusText.font = .b3
        result.append(statusText)
    }
    
    return result
}

private func getStatusColor(keyStatus: KeyStatus) -> Color {
    switch keyStatus {
    case .READY:
        return AssetsColors.success.color()
    case .STOPPED, .ERROR, .TIMEOUT:
        return AssetsColors.alert.color()
    default:
        return AssetsColors.primaryBlue.color()
    }
}

#Preview {
    #if EW
    NavigationContainerView(mockManager: EWManagerMock()) {
        SpinnerViewContainer {
            AdvancedInfoView()
        }
    }
    #endif
}
