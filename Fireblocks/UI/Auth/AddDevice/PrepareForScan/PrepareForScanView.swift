//
//  PrepareForScanView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 04/01/2024.
//

import SwiftUI

struct PrepareForScanView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager

    @State var viewModel: PrepareForScanViewModel
    @State var isTextFieldPresented = false
    
    init(viewModel: PrepareForScanViewModel = PrepareForScanViewModel()) {
        _viewModel = .init(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 0) {
                Image(uiImage: AssetsIcons.addDeviceImage.getIcon())
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                
                Text(LocalizableStrings.prepareForScanHeader)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)
                Button {
                    viewModel.scanQR()
                } label: {
                    HStack {
                        Spacer()
                        Image(AssetsIcons.scanQrCode.rawValue)
                        Text(LocalizableStrings.scanQRCode)
                            .font(.b1)
                        Spacer()
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                    
                }
                .tint(.white)
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .background(AssetsColors.gray2.color())
                .cornerRadius(16)
                
                Text("or")
                    .font(.b1)
                    .foregroundColor(AssetsColors.gray3.color())
                    .padding(16)
                
                ZStack {
                    VStack {
                        Button {
                            isTextFieldPresented = true
                        } label: {
                            HStack {
                                Spacer()
                                Text(LocalizableStrings.enterQRCodeLink)
                                    .font(.b1)
                                Spacer()
                            }
                            .padding(16)
                            .contentShape(Rectangle())
                            
                        }
                        .buttonStyle(.borderless)
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(16)
                        .opacity(isTextFieldPresented ? 0 : 1)
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        Text(LocalizableStrings.copyQRCodeLink)
                            .font(.b1)
                            .padding(16)

                        TextField("", text: $viewModel.requestId)
                            .autocorrectionDisabled()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AssetsColors.gray2.color())
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AssetsColors.gray3.color(), lineWidth: 1)
                            )
                        Spacer()
                    }
                    .opacity(isTextFieldPresented ? 1 : 0)
                }
                Spacer()
                
                Button {
                    viewModel.sendRequestId()
                } label: {
                    HStack {
                        Spacer()
                        Text(LocalizableStrings.continueTitle)
                            .font(.b1)
                        Spacer()
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                    
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .background(AssetsColors.gray2.color())
                .cornerRadius(16)
                .disabled(viewModel.requestId.isTrimmedEmpty)
                .opacity(isTextFieldPresented ? 1 : 0)
            }
            .onAppear() {
                viewModel.setup(coordinator: coordinator, loadingManager: loadingManager)
            }
            .animation(.default, value: isTextFieldPresented)
            .padding(24)
            .navigationTitle(LocalizableStrings.addNewDeviceNavigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CustomBackButtonView()
                }
            }
            .fullScreenCover(isPresented: $viewModel.isQRPresented, content: {
                NavigationStack {
                    GenericControllerNoEnvironments(uiViewType: QRCodeScannerViewController(delegate: viewModel)
                    )
                    .navigationTitle("Scan New Device QR")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                viewModel.isQRPresented = false
                            } label: {
                                Image(.close)
                                    .tint(.white)
                            }
                        }
                    }
                }
            })
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
        self.requestId = "cfbd543a-345d-4fa2-a233-3078f3adbee8"
    }
    
    @MainActor
    override func sendRequestId() {
        if !requestId.isTrimmedEmpty {
            self.gotAddress(address: requestId)
        } else {
            self.loadingManager?.setAlertMessage(error: CustomError.genericError("Missing request ID. Go back and try again"))
        }
    }

    @MainActor
    override func gotAddress(address: String) {
        coordinator?.path.append(NavigationTypes.validateRequestIdView(requestId))
    }

}
