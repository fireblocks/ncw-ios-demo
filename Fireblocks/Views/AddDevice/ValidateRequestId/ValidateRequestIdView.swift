//
//  ValidateRequestIdView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 05/01/2024.
//

import SwiftUI

struct ValidateRequestIdView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ValidateRequestIdViewModel
    @Binding var showLoader: Bool
    @Binding var path: NavigationPath
    
    init(requestId: String, showLoader: Binding<Bool>, path: Binding<NavigationPath>) {
        _viewModel = StateObject(wrappedValue: ValidateRequestIdViewModel(requestId: requestId))
        _showLoader = showLoader
        _path = path
    }
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                GenericHeaderView(icon: AssetsIcons.addDeviceImage.rawValue, subtitle: "Add this device?")
                    .padding(.bottom, 24)
                VStack {
                    Text("Device Details")
                        .font(.subtitle1)
                        .padding(24)
                    VStack(spacing: 16) {
                        HStack {
                            Text("\u{2022} ")
                            Text("Type: \(viewModel.platform ?? Platform.Unknown.rawValue)")
                            Spacer()
                        }
                        .font(.subtitle2)

                        HStack {
                            Text("\u{2022} ")
                            Text("User: \(viewModel.email ?? "")")
                            Spacer()
                        }
                        .font(.subtitle2)

                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)


                }
                .background(.secondary.opacity(0.2))
                .cornerRadius(16)
                .padding(.horizontal, 16)
                
                Spacer()
                
                if let error = viewModel.error {
                    AlertBannerView(message: error)
                        .padding(.vertical, 16)
                }
                
                VStack(spacing: 8) {
                    Button {
                        viewModel.approveJoinWallet()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Add device")
                                .font(.body1)
                            Spacer()
                        }
                        .padding(16)
                        .contentShape(Rectangle())
                        
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .background(AssetsColors.lightBlue.color())
                    .cornerRadius(16)
                    
                    Button {
                        viewModel.didTapCancel()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Cancel")
                                .font(.body1)
                            Spacer()
                        }
                        .padding(16)
                        .contentShape(Rectangle())
                        
                    }
                    .buttonStyle(.borderless)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(16)

                }
                .padding(.bottom, 24)
                Text("QR code expires in: \(viewModel.timeleft)")
                    .font(.body3)
                    .foregroundColor(AssetsColors.gray4.color())
            }
            .padding(.horizontal, 16)
        }
        .onChange(of: viewModel.showLoader) { value in
            showLoader = value
        }
        .onChange(of: viewModel.navigationType) { value in
            if let value {
                path.append(value)
                viewModel.navigationType = nil
            }
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
        .navigationTitle(LocalizableStrings.addNewDeviceNavigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
}

struct ValidateRequestIdView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ValidateRequestIdView(requestId: "AAAAAA", showLoader: .constant(false), path: .constant(NavigationPath()))
        }
    }
}
