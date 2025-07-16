//
//  TakeoverView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 06/03/2025.
//

import SwiftUI
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

struct TakeoverView: View {
    @EnvironmentObject var coordinator: Coordinator
    @Environment(LoadingManager.self) var loadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager

    @State var viewModel: TakeoverViewModel
    
    init(viewModel: TakeoverViewModel = TakeoverViewModel()) {
        _viewModel = .init(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 16) {
                Image("export_keys")
                    
                Text("Use your private key to move assets to a different location. This won’t impact the wallet on this device.")
                    .multilineTextAlignment(.center)
                    .font(.h4)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 34)
                Spacer()
                AlertBannerView(message: LocalizableStrings.takeoverWarningTitle, subtitle: LocalizableStrings.takeoverWarningDescription, color: AssetsColors.warning.color())
                Button {
                    viewModel.getTakeoverFullKeys()
                } label: {
                    HStack(spacing: 8) {
                        Spacer()
                        Text("Export keys")
                        Spacer()
                    }
                    .font(.b2)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.borderedProminent)
                .tint(AssetsColors.gray2.color())
                .background(AssetsColors.gray2.color(), in: .capsule)
                .clipShape(.capsule)
                .contentShape(.rect)

            }
            .padding()
        }
        .onAppear() {
            viewModel.setup(coordinator: coordinator, loadingManager: loadingManager, fireblocksManager: fireblocksManager)
        }
        .navigationTitle("View private keys")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
        .contentMargins(.top, 16)
    }
}

#Preview("TakeoverView") {
    NavigationContainerView {
        SpinnerViewContainer {
            TakeoverView(viewModel: TakeoverViewModelMock())
        }
    }
}

class TakeoverViewModelMock: TakeoverViewModel {
    override func getTakeoverFullKeys() {
        Task {
            await MainActor.run {
                let error = FireblocksManager.shared.getError(.takeover, defaultError: CustomError.takeover)
                self.loadingManager?.setAlertMessage(error: error)
            }
        }
    }
}
