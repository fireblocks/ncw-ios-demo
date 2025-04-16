//
//  Untitled.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 15/04/2025.
//
import SwiftUI

extension ReceivingAddressGenericView {
    @Observable
    class ViewModel: QRCodeScannerViewControllerDelegate {
        var addressText: String = ""
        func gotAddress(address: String) {
            self.addressText = address
        }
        
        static func == (lhs: ViewModel, rhs: ViewModel) -> Bool {
            lhs.addressText == rhs.addressText
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(addressText)
        }
        
    }
}

struct ReceivingAddressGenericView: View {
    var onContinueClicked: (String) -> Void
    var scanTitleResId: LocalizedStringKey
    var scanSubtitleResId: LocalizedStringKey? = nil
    var hint: LocalizedStringKey

    @State var isQRPresented: Bool = false
    @State var addressText: String = ""
    @State var viewModel = ViewModel()

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 24) {
                Image(.qrWeb3)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                HStack(spacing: 16) {
                    Button {
                        isQRPresented = true
                    } label: {
                        Image(.scanQrCode)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .padding(8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AssetsColors.gray2.color())
                    .contentShape(.rect)
                    
                    VStack(spacing: 8) {
                        Text(scanTitleResId)
                            .font(.b1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if let scanSubtitleResId {
                            Text(scanSubtitleResId)
                                .font(.b4)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        isQRPresented = true
                    }
                }
                .padding()
                .background(AssetsColors.gray1.color(), in: .rect(cornerRadius: 16))
                
                Text("Or paste connection link")
                    .font(.b2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AssetsColors.gray2.color())
                            .frame(height: 42)
                            .overlay {
                                Text(hint)
                                    .font(.b4)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .opacity(addressText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 1 : 0)
                                    .padding(.horizontal, 8)
                            }
                        
                        TextField("", text: $addressText)
                            .font(.b2)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 8)
                    }
                }
            }
            
            Spacer()
            
            Text("Scan a QR code or enter an address to continue")
                .font(.b4)
                .foregroundStyle(.white)
            
            Button {
                self.isQRPresented = false
                onContinueClicked(addressText)
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(8)
            }
            .buttonStyle(.borderedProminent)
            .tint(AssetsColors.gray2.color())
            .background(AssetsColors.gray2.color(), in: .capsule)
            .clipShape(.capsule)
            .foregroundStyle(addressText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .primary)
            .contentShape(.rect)
        }
        .padding()
        .onChange(of: viewModel.addressText, { _, newValue in
            DispatchQueue.main.async {
                self.isQRPresented = false
                self.onContinueClicked(newValue)
            }
        })
        .fullScreenCover(isPresented: $isQRPresented, content: {
            NavigationStack {
                GenericControllerNoEnvironments(
                    uiViewType: QRCodeScannerViewController(delegate: viewModel)
                )
                .navigationTitle("Scan Connection QR")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isQRPresented = false
                        } label: {
                            Image(.close)
                                .tint(.white)
                        }
                    }
                }
            }
        })
        .animation(.default, value: addressText)
        .animation(.default, value: viewModel.addressText)
    }
    
}
