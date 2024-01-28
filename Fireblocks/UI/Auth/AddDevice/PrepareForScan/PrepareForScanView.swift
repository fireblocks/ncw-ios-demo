//
//  PrepareForScanView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 04/01/2024.
//

import SwiftUI

struct PrepareForScanView: View {
    @StateObject var viewModel: PrepareForScanViewModel
    @State var isTextFieldPresented = false
    
    var body: some View {
        ScrollView {
            ZStack {
                Color.black
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    Image(uiImage: AssetsIcons.addDeviceImage.getIcon())
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    
                    Text("Scan the QR code on your new device to add it to your BitVault wallet. ")
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 32)
                    Button {
                        viewModel.scanQR()
                    } label: {
                        HStack {
                            Spacer()
                            Image(AssetsIcons.scanQrCode.rawValue)
                            Text("Scan QR Code")
                                .font(.body1)
                            Spacer()
                        }
                        .padding(16)
                        .contentShape(Rectangle())
                        
                    }
                    .tint(.white)
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .background(AssetsColors.gray1.color())
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
                                    Text("Enter QR code link")
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
                            Text("Copy the QR code link")
                                .font(.body1)
                            
                            TextField("", text: $viewModel.requestId)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AssetsColors.gray1.color())
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
                            Text("Continue")
                                .font(.body1)
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
                .onAppear() {
                    viewModel.didInit()
                }
                .animation(.default, value: isTextFieldPresented)
                .padding(24)
                .navigationTitle(LocalizableStrings.addNewDeviceNavigationBar)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct PrepareForScanView_Previews: PreviewProvider {
    static var previews: some View {
        PrepareForScanView(viewModel: PrepareForScanViewModel())
    }
}
