//
//  PrepareForScanView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 04/01/2024.
//

import SwiftUI

struct PrepareForScanView: View {
    @EnvironmentObject var coordinator: Coordinator
    @Environment(LoadingManager.self) var loadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager

    @State var viewModel: PrepareForScanViewModel
    @State var isTextFieldPresented = false
    
    init(viewModel: PrepareForScanViewModel = PrepareForScanViewModel()) {
        _viewModel = .init(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            ReceivingAddressGenericView(
                onContinueClicked: { uri in
                    viewModel.qrCode = uri
                    viewModel.sendRequestId()
                },
                scanTitleResId: "Scan the QR code on your new device",
                hint: "Enter the QR code link"
            )
        }
        .navigationTitle("Add new device")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
        .onAppear() {
            viewModel.setup(coordinator: coordinator, loadingManager: loadingManager)
        }
    }    
}

#Preview("Empty") {
    NavigationContainerView {
        SpinnerViewContainer {
            PrepareForScanView(viewModel: PrepareForScanViewModel())
                .environmentObject(FireblocksManager.shared)
        }

    }
}

#Preview("Full") {
    NavigationContainerView {
        SpinnerViewContainer {
            PrepareForScanView(viewModel: PrepareForScanViewModelMock())
                .environmentObject(FireblocksManager.shared)
        }

    }
}


class PrepareForScanViewModelMock: PrepareForScanViewModel {
    override init() {
        super.init()
        self.qrCode = "cfbd543a-345d-4fa2-a233-3078f3adbee8"
    }
    
    @MainActor
    override func sendRequestId() {
        if !qrCode.isTrimmedEmpty {
            self.gotAddress(address: qrCode)
        } else {
            self.loadingManager?.setAlertMessage(error: CustomError.genericError("Missing request ID. Go back and try again"))
        }
    }

    @MainActor
    override func gotAddress(address: String) {
        coordinator?.path.append(NavigationTypes.validateRequestIdView(qrCode))
    }

}
