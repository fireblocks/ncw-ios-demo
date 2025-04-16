//
//  Untitled.swift
//  Fireblocks
//
//  Created by Ofir Barzilay on 15/04/2025.
//
import SwiftUI

struct ReceivingAddressGenericView: View {
    @Binding var addressText: String
    @Binding var isQRPresented: Bool

    var onContinueClicked: (String) -> Void
    var scanTitleResId: LocalizedStringKey
    var scanSubtitleResId: LocalizedStringKey? = nil
    var hint: LocalizedStringKey
    
    // Add delegate to handle QR scanning
    class QRScanDelegate: NSObject {
        var onCodeScanned: (String) -> Void
        
        init(onCodeScanned: @escaping (String) -> Void) {
            self.onCodeScanned = onCodeScanned
        }
    }
    
    // Create a delegate property
    @State private var qrDelegate: QRScanDelegate?
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 24) {
                Image(.qrWeb3)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                HStack(spacing: 16) {
                    Button {
                        setupQRDelegate()
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
                        setupQRDelegate()
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
        .fullScreenCover(isPresented: $isQRPresented, content: {
            NavigationStack {
                if let delegate = qrDelegate {
                    GenericControllerNoEnvironments(
                        uiViewType: QRCodeScannerViewController(delegate: delegate)
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
            }
        })
        .animation(.default, value: addressText)
    }
    
    private func setupQRDelegate() {
        qrDelegate = QRScanDelegate { code in
            addressText = code
            isQRPresented = false
        }
    }
}

// Make QRScanDelegate conform to necessary protocol for QRCodeScannerViewController
extension ReceivingAddressGenericView.QRScanDelegate: QRCodeScannerViewControllerDelegate {
    func gotAddress(address: String) {
        
    }
    
    func didScanCode(_ code: String) {
        onCodeScanned(code)
    }
}
