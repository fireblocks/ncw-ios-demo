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
    @EnvironmentObject var coordinator: Coordinator
    @EnvironmentObject var loadingManager: LoadingManager
    @EnvironmentObject var fireblocksManager: FireblocksManager

    @State var viewModel: AddDeviceQRViewModel
    
    init(viewModel: AddDeviceQRViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
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
                                    Text(LocalizableStrings.launchOnExistingDevice)
                                        .font(.b1)
                                    Spacer()
                                }
                                VerticalSeparator()
                                HStack {
                                    Bullet(text: "2")
                                    Text(LocalizableStrings.openSettingsMenu)
                                        .font(.b1)
                                    Image(uiImage: AssetsIcons.settings.getIcon())
                                    Spacer()
                                }
                                VerticalSeparator()
                                HStack {
                                    Bullet(text: "3")
                                    Text(LocalizableStrings.tapAddNewDevice)
                                        .font(.b1)
                                    Spacer()
                                }
                                VerticalSeparator()
                                HStack {
                                    Bullet(text: "4")
                                    Text(LocalizableStrings.scanTheQRCode)
                                        .font(.b1)
                                    Spacer()
                                }
                            }
                            .padding(.bottom, 40)
                            
                            AddDeviceQRInnerView(image: generateQRCode(from: viewModel.url, size: CGSize(width: 171.0, height: 171.0)), url: viewModel.url) {
                                self.loadingManager.toastMessage = "Copied!"
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
                    .font(.b3)
                    .foregroundColor(AssetsColors.gray4.color())
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        viewModel.dismiss()
                    } label: {
                        Image(uiImage: AssetsIcons.close.getIcon())
                    }
                    .tint(.white)
                    .opacity(viewModel.isToolbarHidden ? 0 : 1)
                }
            }
        }
        .onAppear() {
            viewModel.setup(loadingManager: loadingManager, coordinator: coordinator, fireblocksManager: fireblocksManager)
        }
        .navigationTitle(LocalizableStrings.addNewDeviceNavigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled()
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: CustomBackButtonView())
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
                .font(.b1)
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
                    .tint(.white)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 16)
            }
        }
        .padding(.top, 40)
        .background(AssetsColors.gray1.color())
        .cornerRadius(16)

    }
}

#Preview {
    NavigationContainerView {
        SpinnerViewContainer {
            AddDeviceQRView(viewModel: AddDeviceQRViewModelMock(requestId: "XXXXXX", email: "aaa@bbb.cc", expiredInterval: 5))
        }
    }
}

class AddDeviceQRViewModelMock: AddDeviceQRViewModel {
    override func didQRTimeExpired() {
        let vm = EndFlowFeedbackView.ViewModel(icon: AssetsIcons.errorImage.rawValue, title: LocalizableStrings.approveJoinWalletCanceled, subTitle: LocalizableStrings.addDeviceFailedSubtitle, buttonTitle: LocalizableStrings.tryAgain, actionButton:  {
            self.coordinator.path = NavigationPath()
        }, rightToolbarItemIcon: AssetsIcons.close.rawValue, rightToolbarItemAction: {
            self.coordinator.path = NavigationPath()
        }, didFail: true, canGoBack: false)
        self.coordinator.path.append(NavigationTypes.feedback(vm))
    }

}
