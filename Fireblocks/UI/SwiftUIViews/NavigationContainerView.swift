//
//  NavigationContainerView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI
import EmbeddedWalletSDKDev

enum NavigationTypes: Hashable {
    case signIn(SignInView.ViewModel)
    case joinOrRecover
    case recoverWallet(Bool)
    case addDevice
    case addDeviceQR(String, String)
    case feedback(EndFlowFeedbackView.ViewModel)
    case backup(Bool)
    case takeover
    case joinDevice
    case settings
    case info
    case generateKeys
    
    #if EW
    case createConnection(Int)
    case submitConnection(CreateWeb3ConnectionResponse)
    case connectionDetails(Web3Connection, Bool)
//    case scanQR(any QRCodeScannerViewControllerDelegate)
    case NFTToken(TokenOwnershipResponse)
    case transferNFT(TokenOwnershipResponse)
    case nftFee(TokenOwnershipResponse, String)
    #endif
}

class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
}

struct NavigationContainerView<Content: View>: View {
    @StateObject var coordinator = Coordinator()
    @StateObject var fireblocksManager = FireblocksManager.shared
    @StateObject var googleSignInManager = GoogleSignInManager()
    @StateObject var appleSignInManager = AppleSignInManager()
    #if EW
    @State var ewManager: EWManager
    var mockManager: EWManagerMock?
    
    init(coordinator: Coordinator = Coordinator(), fireblocksManager: FireblocksManager = FireblocksManager.shared, googleSignInManager: GoogleSignInManager = GoogleSignInManager(), appleSignInManager: AppleSignInManager = AppleSignInManager(), mockManager: EWManagerMock? = nil, @ViewBuilder content: @escaping () -> Content) {
        _coordinator = StateObject(wrappedValue: coordinator)
        _fireblocksManager = StateObject(wrappedValue: fireblocksManager)
        _googleSignInManager = StateObject(wrappedValue: googleSignInManager)
        _appleSignInManager = StateObject(wrappedValue: appleSignInManager)
        _ewManager = State(initialValue: EWManager(mockManager: mockManager))
        self.mockManager = mockManager
        self.content = content()
    }
//
//    init(isPreview: Bool = false) {
//        _ewManager = State(initialValue: isPreview ? EWManager(isPreview: true) : EWManager.shared)
//    }
//#else
    #endif
    
    @ViewBuilder var content: Content
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            content
                .toolbarBackground(AssetsColors.background.color(), for: .navigationBar)
                .environmentObject(coordinator)
                .environmentObject(fireblocksManager)
                .environmentObject(googleSignInManager)
                .environmentObject(appleSignInManager)
            #if EW
                .environment(ewManager)
            #endif
            .navigationDestination(for: NavigationTypes.self) { type in
                switch type {
                case .signIn(let viewModel):
                    SpinnerViewContainer {
                        SignInView()
                            .environmentObject(viewModel)
                            .environmentObject(coordinator)
                            .environmentObject(fireblocksManager)
                            .environmentObject(googleSignInManager)
                            .environmentObject(appleSignInManager)
                    }
                case .joinOrRecover:
                    SpinnerViewContainer {
                        JoinOrRecoverView()
                            .environmentObject(coordinator)
                    }
                case .recoverWallet(let redirect):
                    SpinnerViewContainer {
                        RecoverWalletView(redirect: redirect)
                            .environmentObject(coordinator)
                            .environmentObject(fireblocksManager)
                            .environmentObject(googleSignInManager)
                    }
                case .addDevice:
                    SpinnerViewContainer {
                        AddDeviceView()
                            .environmentObject(coordinator)
                            .environmentObject(fireblocksManager)
                    }
                case .addDeviceQR(let requestId, let email):
                    SpinnerViewContainer {
                        AddDeviceQRView(viewModel: AddDeviceQRViewModel(requestId: requestId, email: email))
                            .environmentObject(coordinator)
                            .environmentObject(fireblocksManager)
                    }
                case .feedback(let viewModel): 
                    SpinnerViewContainer {
                        EndFlowFeedbackView(viewModel: viewModel, content: nil)                     .environmentObject(coordinator)
                            .environmentObject(fireblocksManager)
                    }
                case .backup(let redirect):
                    SpinnerViewContainer {
                        BackupWalletView(redirect: redirect)
                            .environmentObject(coordinator)
                            .environmentObject(fireblocksManager)
                            .environmentObject(googleSignInManager)

                    }
                case .generateKeys:
                    SpinnerViewContainer {
                        GenerateKeysView()
                            .environmentObject(fireblocksManager)
                            .environmentObject(coordinator)

                    }
                case .takeover:
                    TakeoverViewControllerRep()
                case .joinDevice:
                    PrepareForScanHostingVCRep()
                case .info:
                    AdvancedInfoViewControllerRep()
                case .settings:
                    SpinnerViewContainer {
                        SettingsView()
                            .environmentObject(coordinator)
                    }
                #if EW
                case .createConnection(let accountId):
                    SpinnerViewContainer {
                        EWWeb3ConnectionURI(accountId: accountId)
                            .environmentObject(coordinator)
                            .environment(ewManager)
                    }
                case .submitConnection(let response):
                    SpinnerViewContainer {
                        EWWeb3ConnectionSubmitView(response: response)
                            .environmentObject(coordinator)
                            .environment(ewManager)
                    }
                case .connectionDetails(let connection, let canRemove):
                    SpinnerViewContainer {
                        EWWeb3ConnectionDetailsView(connection: connection, canRemove: canRemove)
                            .environmentObject(coordinator)
                            .environment(ewManager)
                    }
//                case .scanQR(let delegate):
//                    GenericController(uiViewType: QRCodeScannerViewController(delegate: delegate)
//                    )
                case .transferNFT(let token):
                    SpinnerViewContainer {
                        EWTransferNFTView(token: token)
                            .environmentObject(coordinator)
                            .environment(ewManager)

                    }
                case .nftFee(let token, let address):
                    SpinnerViewContainer {
                        EWNFTFeeView(token: token, address: address)
                            .environmentObject(coordinator)
                            .environment(ewManager)

                    }
                case .NFTToken(let token):
                    SpinnerViewContainer {
                        EWNFTDetailsView(token: token)
                            .environmentObject(coordinator)
                            .environment(ewManager)

                    }
                #endif
                }
            }
        }
    }
}

#Preview {
    NavigationContainerView() {
        Text("Hello")
    }
}
