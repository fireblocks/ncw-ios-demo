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
    @EnvironmentObject var loadingManager: LoadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager

    @State var viewModel: TakeoverViewModel
    
    init(viewModel: TakeoverViewModel = TakeoverViewModel()) {
        _viewModel = .init(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 16) {
                Text("Copy the Private Keys and save them in a secure location. You are now the responsible for their security.")
                Spacer()
                AlertBannerView(message: LocalizableStrings.takeoverWarningTitle, subtitle: LocalizableStrings.takeoverWarningDescription, color: AssetsColors.warning.color())
                Button {
                    viewModel.getTakeoverFullKeys()
                } label: {
                    HStack(spacing: 8) {
                        Spacer()
                        Text("Continue")
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
        .navigationTitle("Takeover")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
    }
}

#Preview("Error") {
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
                self.loadingManager?.setAlertMessage(error: CustomError.genericError("Failed to takeover keys"))
            }
        }
    }
}
