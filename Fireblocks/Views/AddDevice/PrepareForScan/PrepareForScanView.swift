//
//  PrepareForScanView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 04/01/2024.
//

import SwiftUI

struct PrepareForScanView: View {
    @StateObject var viewModel = PrepareForScanViewModel()
    @State var isTextFieldPresented = false
    @Binding var path: NavigationPath
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack(spacing: 0) {
                    GenericHeaderView(icon: AssetsIcons.addDeviceImage.rawValue, subtitle: LocalizableStrings.prepareForScanHeader)
                        .padding(.bottom, 32)

                    Button {
                        viewModel.scanQR()
                    } label: {
                        HStack {
                            Spacer()
                            Image(AssetsIcons.scanQrCode.rawValue)
                            Text(LocalizableStrings.scanQRCode)
                                .font(.body1)
                            Spacer()
                        }
                        .padding(16)
                        .contentShape(Rectangle())
                        
                    }
                    .tint(.primary)
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .background(.secondary.opacity(0.2))
                    .cornerRadius(16)
                    
                    Text("or")
                        .font(.body1)
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
                                        .font(.body1)
                                    Spacer()
                                }
                                .padding(16)
                                .contentShape(Rectangle())
                                
                            }
                            .buttonStyle(.borderless)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(16)
                            .opacity(isTextFieldPresented ? 0 : 1)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            Text(LocalizableStrings.copyQRCodeLink)
                                .font(.body1)
                            
                            TextField("", text: $viewModel.requestId)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.secondary.opacity(0.2))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AssetsColors.gray2.color(), lineWidth: 1)
                                )
                                .onTapGesture {
                                    viewModel.error = nil
                                }
                            Spacer()
                        }
                        .opacity(isTextFieldPresented ? 1 : 0)
                    }
                    Spacer()
                    
                    if let error = viewModel.error {
                        AlertBannerView(message: error)
                            .padding(.vertical, 16)
                    }
                    
                    Button {
                        viewModel.sendRequestId()
                    } label: {
                        HStack {
                            Spacer()
                            Text(LocalizableStrings.continueTitle)
                                .font(.body1)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(16)
                        .contentShape(Rectangle())
                        
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.requestId.isTrimmedEmpty ? AssetsColors.darkerBlue.color() : AssetsColors.lightBlue.color())
                    .cornerRadius(16)
                    .disabled(viewModel.requestId.isTrimmedEmpty)
                    .opacity(isTextFieldPresented ? 1 : 0)
                }
                .onChange(of: viewModel.vc) { vc in
                    if vc != nil {
                        path.append(viewModel)
                        viewModel.vc = nil
                    }
                }
                .onChange(of: viewModel.navigationType) { type in
                    if let type {
                        path.append(type)
                        viewModel.navigationType = nil
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            path.removeLast()
                        } label: {
                            Image(AssetsIcons.back.rawValue)
                        }
                        .tint(.primary)
                    }
                }
                .animation(.default, value: isTextFieldPresented)
                .padding(24)
                .navigationTitle(LocalizableStrings.addNewDeviceNavigationBar)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
            }
        }
    }
}

struct PrepareForScanView_Previews: PreviewProvider {
    static var previews: some View {
        PrepareForScanView(path: .constant(NavigationPath()))
    }
}
