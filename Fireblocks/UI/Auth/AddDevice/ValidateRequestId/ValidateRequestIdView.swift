//
//  ValidateRequestIdView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 05/01/2024.
//

import SwiftUI

struct ValidateRequestIdView: View {
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager

    @Environment(\.dismiss) var dismiss
    @State var viewModel: ValidateRequestIdViewModel
        
    init(viewModel: ValidateRequestIdViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                Image(uiImage: AssetsIcons.addDeviceImage.getIcon())
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                
                Text("Add this device?")
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)
                
                VStack {
                    Text("Device Details")
                        .font(.b1)
                        .padding(24)
                    VStack(spacing: 16) {
                        HStack {
                            Text("\u{2022} ")
                            Text("Type: \(viewModel.platform ?? Platform.Unknown.rawValue)")
                            Spacer()
                        }
                        .font(.b2)

                        HStack {
                            Text("\u{2022} ")
                            Text("User: \(viewModel.email ?? "")")
                            Spacer()
                        }
                        .font(.b2)

                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)


                }
                .background(AssetsColors.gray1.color())
                .cornerRadius(16)
                .padding(.horizontal, 16)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Button {
                        viewModel.approveJoinWallet()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Add device")
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
                    
                    Button {
                        viewModel.didTapCancel()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Cancel")
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

                }
                .padding(.bottom, 24)
                Text("QR code expires in: \(viewModel.timeleft)")
                    .font(.b3)
                    .foregroundColor(AssetsColors.gray4.color())
            }
            .padding(.horizontal, 16)
        }
        .onAppear() {
            viewModel.setup(coordinator: coordinator, loadingManager: loadingManager, fireblocksManager: fireblocksManager)
        }
        .navigationTitle(LocalizableStrings.addNewDeviceNavigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CustomBackButtonView()
            }
        }

    }
}

#Preview {
    NavigationContainerView {
        SpinnerViewContainer {
            ValidateRequestIdView(viewModel: ValidateRequestIdViewModelMock(requestId: UUID().uuidString, expiredInterval: 5.seconds))
        }
    }
}

class ValidateRequestIdViewModelMock: ValidateRequestIdViewModel {
    override func qrData(encoded: String) -> JoinRequestData? {
        JoinRequestData(requestId: requestId, platform: Platform.iOS.rawValue, email: "dsgabay@fireblocks.com")
    }
}
