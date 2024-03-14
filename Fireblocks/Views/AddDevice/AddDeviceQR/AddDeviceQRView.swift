//
//  AddDeviceQRView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 03/01/2024.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct AddDeviceQRView: View {
    @EnvironmentObject var bannerErrorsManager: BannerErrorsManager
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AddDeviceQRViewModel
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    @Binding var toast: String?
    @Binding var showLoader: Bool
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            VStack {
                Color(.reverse)
                    .frame(height: 12)

                ScrollView {
                    VStack {
                        VStack(spacing: 8) {
                            VStack(spacing: 8) {
                                HStack {
                                    Bullet(text: "1")
                                    Text(LocalizableStrings.launchOnExistingDevice)
                                        .font(.subtitle1)
                                    Spacer()
                                }
                                VerticalSeparator()
                                HStack {
                                    Bullet(text: "2")
                                    Text(LocalizableStrings.openSettingsMenu)
                                        .font(.subtitle1)
                                    Image(uiImage: AssetsIcons.settings.getIcon())
                                    Spacer()
                                }
                                VerticalSeparator()
                                HStack {
                                    Bullet(text: "3")
                                    Text(LocalizableStrings.tapAddNewDevice)
                                        .font(.subtitle1)
                                    Spacer()
                                }
                                VerticalSeparator()
                                HStack {
                                    Bullet(text: "4")
                                    Text(LocalizableStrings.scanTheQRCode)
                                        .font(.subtitle1)
                                    Spacer()
                                }
                            }
                            .padding(.bottom, 40)
                            
                            AddDeviceQRInnerView(image: generateQRCode(from: viewModel.url, size: CGSize(width: 171.0, height: 171.0)), url: viewModel.url) {
                                bannerErrorsManager.toastMessage = ToastItem(icon: AssetsIcons.checkMark.rawValue, message: "copied")
                            }
                            
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
                Text("\(LocalizableStrings.qrCodeExpiresIn) \(viewModel.timeleft)")
                    .font(.body3)
                    .foregroundColor(AssetsColors.gray4.color())
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        viewModel.dismiss()
                        dismiss()
                    } label: {
                        Image(uiImage: AssetsIcons.close.getIcon())
                    }
                    .tint(.primary)
                    .opacity(viewModel.isToolbarHidden ? 0 : 1)
                }
            }
        }
        .toast(item: bannerErrorsManager.toastMessage)
        .onChange(of: viewModel.showLoader) { value in
            showLoader = value
        }
        .onChange(of: viewModel.navigationType) { value in
            if let value {
                path.append(value)
            }
        }
        .navigationTitle(LocalizableStrings.addNewDeviceNavigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .interactiveDismissDisabled()
    }
    
    func generateQRCode(from url: String?, size: CGSize) -> Image {
        guard let url else {
            return Image(systemName: "xmark.circle")
        }
        
        filter.message = Data(url.utf8)
        filter.correctionLevel = "Q"
        
        if let output = filter.outputImage {
            let x = size.width / output.extent.size.width
            let y = size.height / output.extent.size.height

            let scaled = output.transformed(by: CGAffineTransform(scaleX: x, y: y))
            if let cg = CIContext().createCGImage(scaled, from: scaled.extent) {
                return Image(uiImage: UIImage(cgImage: cg))
            }
        }

        return Image(systemName: "xmark.circle")

    }

}

struct AddDeviceQRInnerView: View {
    let image: Image
    let url: String?
    let action: () -> ()
    private let imageWidth = 171.0

    var body: some View {
        VStack(spacing: 0) {
            image
                .resizable()
                .scaledToFit()
                .frame(width: imageWidth, height: imageWidth)
                .padding(.bottom, 24)
            
            Text(LocalizableStrings.qrCodeLink)
                .font(.subtitle1)
                .padding(.top, 16)
            
            if let url = url {
                HStack {
                    Text(url)
                        .foregroundColor(AssetsColors.gray4.color())
                        .padding(8)
                        .lineLimit(1)
                    Button {
                        action()
                        UIPasteboard.general.string = url
                    } label: {
                        Image(uiImage: AssetsIcons.copy.getIcon())
                    }
                    .tint(.primary)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 16)
            }
        }
        .padding(.top, 40)
        .background(.secondary.opacity(0.2))
        .cornerRadius(16)

    }
}


//struct AddDeviceQRView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddDeviceQRView(requestId: "AAAA", email: "BBB")
//    }
//}
