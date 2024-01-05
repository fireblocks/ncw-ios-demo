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
        
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            VStack {
                Color.black
                    .frame(height: 12)
                
                Image(uiImage: AssetsIcons.addDeviceImage.getIcon())
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                
                Text("Add this device?")
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)
                
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
                .background(AssetsColors.gray1.color())
                .cornerRadius(16)
                .padding(.horizontal, 16)
                
                Spacer()

                VStack(spacing: 8) {
                    Button {
                        print("add device")
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
                        dismiss()
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
                .padding(.vertical, 24)
                Text("QR code expires in: \(viewModel.timeleft)")
                    .font(.body3)
                    .foregroundColor(AssetsColors.gray4.color())
            }
        }
        .navigationTitle(LocalizableStrings.addNewDeviceNavigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .interactiveDismissDisabled()
    }
}

struct ValidateRequestIdView_Previews: PreviewProvider {
    static var previews: some View {
        ValidateRequestIdView(viewModel: ValidateRequestIdViewModel(requestId: "AAAAAA"))
    }
}
