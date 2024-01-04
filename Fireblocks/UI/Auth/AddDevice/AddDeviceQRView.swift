//
//  AddDeviceQRView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 03/01/2024.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct AddDeviceQRView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AddDeviceQRViewModel
    @State var timeleft = ""
    
    private let imageWidth = 171.0
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    init(requestId: String, email: String?) {
        _viewModel = StateObject(wrappedValue: AddDeviceQRViewModel(requestId: requestId, email: email))
    }
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            VStack {
                Color.black
                    .frame(height: 12)

                ScrollView {
                    VStack {
                        VStack(spacing: 8) {
                            VStack(spacing: 8) {
                                HStack {
                                    Bullet(text: "1")
                                    Text("Launch BitVault on your existing device.")
                                        .font(.subtitle1)
                                    Spacer()
                                }
                                VerticalSeparator()
                                HStack {
                                    Bullet(text: "2")
                                    Text("Open the settings menu.")
                                        .font(.subtitle1)
                                    Image(uiImage: AssetsIcons.settings.getIcon())
                                    Spacer()
                                }
                                VerticalSeparator()
                                HStack {
                                    Bullet(text: "3")
                                    Text("Tap “Add new device”.")
                                        .font(.subtitle1)
                                    Spacer()
                                }
                                VerticalSeparator()
                                HStack {
                                    Bullet(text: "4")
                                    Text("Scan the QR code.")
                                        .font(.subtitle1)
                                    Spacer()
                                }
                            }
                            .padding(.bottom, 40)
                            
                            VStack(spacing: 0) {
                                Image(uiImage: generateQRCode(from: viewModel.url))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: imageWidth, height: imageWidth)
                                    .padding(.bottom, 24)
                                
                                Text("QR code link")
                                    .font(.subtitle1)
                                    .padding(.top, 16)
                                
                                if let url = viewModel.url {
                                    HStack {
                                        Text(url)
                                            .foregroundColor(AssetsColors.gray4.color())
                                            .padding(8)
                                            .lineLimit(1)
                                        Button {
                                            viewModel.showToast()
                                            UIPasteboard.general.string = url
                                        } label: {
                                            Image(uiImage: AssetsIcons.copy.getIcon())
                                        }
                                        .tint(.white)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.bottom, 16)
                                }
                                
//                                Text(decoded)
//                                Button("Decode") {
//                                    viewModel.showIndicator()
//                                    if let url = viewModel.url {
//                                        decoded = viewModel.qrData(encoded: url.base64Decoded() ?? "")?.email ?? "Wrong"
//                                    }
//                                }
                            }
                            .padding(.top, 40)
                            .background(AssetsColors.gray1.color())
                            .cornerRadius(16)
                            Spacer()
                        }
                        .padding(.horizontal, 26)
                    }
                    .padding(.horizontal)
                }
                Text("AAAAAAAA")
                    .opacity(0)

            }
            
            VStack {
                Spacer()
                Text("QR code expires in: \(viewModel.timeleft)")
                    .font(.body3)
                    .foregroundColor(AssetsColors.gray4.color())
            }
            .onChange(of: viewModel.timeleft, perform: { newValue in
                timeleft = newValue
            })
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Image(uiImage: AssetsIcons.close.getIcon())
                    }
                    .tint(.white)
                    .opacity(viewModel.isToolbarHidden ? 0 : 1)
                }
            }
        }
        .navigationTitle(LocalizableStrings.mpcKeysAddDeviceHeader)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .interactiveDismissDisabled()
    }
    
    func generateQRCode(from url: String?) -> UIImage {
        guard let url else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
        
        filter.message = Data(url.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()

    }

}

struct Bullet: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.subtitle3)
            .contentShape(Rectangle())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AssetsColors.gray1.color())
            .cornerRadius(4)
    }
}

struct VerticalSeparator: View {
    var body: some View {
        HStack {
            HStack {}
                .frame(width: 4, height: 32)
                .background(AssetsColors.gray1.color())
                .cornerRadius(4)
                .padding(.horizontal, 11)
            Spacer()
        }
    }
}

struct AddDeviceQRView_Previews: PreviewProvider {
    static var previews: some View {
        AddDeviceQRView(requestId: "AAAA", email: "BBB")
    }
}
