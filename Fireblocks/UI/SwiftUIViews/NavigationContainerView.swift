//
//  NavigationContainerView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif
#if DEV
import FireblocksDev
#else
import FireblocksSDK
#endif

enum NavigationTypes: Hashable {
    case signIn
    case joinOrRecover
    case recoverWallet(Bool)
    case addDevice
    case addDeviceQR(String, String)
    case feedback(EndFlowFeedbackView.ViewModel)
    case backup(Bool)
    case takeover
    case derivedKeysView(Set<FullKey>)
    case joinDevice
    case validateRequestIdView(String)
    case settings
    case info
    case genericController(UIViewController, String)
    case transactionRecipient(FBTransaction)
    case selectFee(FBTransaction)
    case approveTransaction(FBTransaction, Bool)
    
    #if EW
    case createConnection(Web3DataModel)
    case submitConnection(Web3DataModel)
    case connectionDetails(Web3DataModel)
//    case scanQR(any QRCodeScannerViewControllerDelegate)
    case NFTToken(NFTDataModel)
    case transferNFT(NFTDataModel)
    case nftFee(NFTDataModel)
    case nftPreview(NFTDataModel)
    #endif
}

protocol SwiftUIEnvironmentBridge: AnyObject {
    #if EW
    func setEnvironment(loadingManager: LoadingManager, coordinator: Coordinator, ewManager: EWManager)
    #else
    func setEnvironment(loadingManager: LoadingManager, coordinator: Coordinator)
    #endif
}

extension SwiftUIEnvironmentBridge {
    #if EW
    func setEnvironment(loadingManager: LoadingManager, coordinator: Coordinator, ewManager: EWManager) {}
    #else
    func setEnvironment(loadingManager: LoadingManager, coordinator: Coordinator) {}
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
                case .signIn:
                    SpinnerViewContainer {
                        SignInView()
                            .environmentObject(SignInViewModel.shared)
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
                case .validateRequestIdView(let requestId):
                    SpinnerViewContainer {
                        ValidateRequestIdView(viewModel: ValidateRequestIdViewModel(requestId: requestId))
                            .environmentObject(coordinator)
                            .environmentObject(fireblocksManager)
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
                        EndFlowFeedbackView(viewModel: viewModel)                     .environmentObject(coordinator)
                            .environmentObject(fireblocksManager)
                    }
                case .backup(let redirect):
                    SpinnerViewContainer {
                        BackupWalletView(redirect: redirect)
                            .environmentObject(coordinator)
                            .environmentObject(fireblocksManager)
                            .environmentObject(googleSignInManager)

                    }
                case .takeover:
                    SpinnerViewContainer {
                        TakeoverView()
                            .environmentObject(fireblocksManager)
                            .environmentObject(coordinator)

                    }
                case .derivedKeysView(let keys):
                    DeriveKeysView(viewModel: DeriveKeysView.ViewModel(privateKeys: keys))
                case .joinDevice:
                    SpinnerViewContainer {
                        PrepareForScanView()
                            .environmentObject(fireblocksManager)
                            .environmentObject(coordinator)

                    }
                case .transactionRecipient(let transaction):
                    SpinnerViewContainer {
                        SendToView(viewModel: SendToViewModel(transaction: transaction))
                            .environmentObject(coordinator)
                            #if EW
                                .environment(ewManager)
                            #endif

                    }
                case .selectFee(let transaction):
                    SpinnerViewContainer {
                        FeeRateView(viewModel: FeeRateViewModel(transaction: transaction))
                            .environmentObject(coordinator)
                            #if EW
                                .environment(ewManager)
                            #endif

                    }
                case .info:
                    SpinnerViewContainer {
                        AdvancedInfoView()
                            .environmentObject(fireblocksManager)
                    }
                case .settings:
                    SpinnerViewContainer {
                        SettingsView()
                            .environmentObject(coordinator)
                    }
                case .genericController(let controller, let title):
                    SpinnerViewContainer {
                        GenericController(uiViewType: controller)
                            .environmentObject(coordinator)
                        #if EW
                            .environment(ewManager)
                        #endif
                            .navigationTitle(title)
                            .navigationBarTitleDisplayMode(.inline)
                            .tint(.white)
                            .navigationBarBackButtonHidden()
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    CustomBackButtonView()
                                }
                            }
                    }
                case .approveTransaction(let transaction, let fromCreate):
                    SpinnerViewContainer {
                        ApproveTransactionView(transaction: transaction, fromCreate: fromCreate)
                            .environmentObject(coordinator)
                            .environmentObject(fireblocksManager)
                            #if EW
                            .environment(ewManager)
                            #endif
                    }
                #if EW
                case .createConnection(let dataModel):
                    SpinnerViewContainer {
                        EWWeb3ConnectionURI(dataModel: dataModel)
                            .environmentObject(coordinator)
                            .environment(ewManager)
                    }
                case .submitConnection(let dataModel):
                    SpinnerViewContainer {
                        EWWeb3ConnectionSubmitView(dataModel: dataModel)
                            .environmentObject(coordinator)
                            .environment(ewManager)
                    }
                case .connectionDetails(let dataModel):
                    SpinnerViewContainer {
                        EWWeb3ConnectionDetailsView(dataModel: dataModel)
                            .environmentObject(coordinator)
                            .environment(ewManager)
                    }
//                case .scanQR(let delegate):
//                    GenericController(uiViewType: QRCodeScannerViewController(delegate: delegate)
//                    )
                case .transferNFT(let dataModel):
                    SpinnerViewContainer {
                        EWTransferNFTView(dataModel: dataModel)
                            .environmentObject(coordinator)
                            .environment(ewManager)

                    }
                case .nftFee(let dataModel):
                    SpinnerViewContainer {
                        EWNFTFeeView(dataModel: dataModel)
                            .environmentObject(coordinator)
                            .environment(ewManager)

                    }
                case .nftPreview(let dataModel):
                    SpinnerViewContainer {
                        EWNFTPreviewView(dataModel: dataModel)
                            .environmentObject(coordinator)
                            .environment(ewManager)

                    }
                case .NFTToken(let dataModel):
                    SpinnerViewContainer {
                        EWNFTDetailsView(dataModel: dataModel)
                            .environmentObject(coordinator)
                            .environment(ewManager)

                    }
                #endif
                }
            }
            .navigationViewStyle(.stack)
            .toolbarBackground(AssetsColors.background.color(), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)

        }
    }
}

#Preview {
    NavigationContainerView {
        Text("Hello")
    }
}
