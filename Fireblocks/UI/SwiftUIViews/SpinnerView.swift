//
//  SpinnerView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI
#if EW
    #if DEV
    import EmbeddedWalletSDKDev
    #else
    import EmbeddedWalletSDK
    #endif
#endif

class LoadingManager: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var alertMessage: String? {
        didSet {
            if alertMessage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.alertMessage = nil
                }
            }
        }
    }
    
    @Published var toastMessage: String? {
        didSet {
            if toastMessage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.toastMessage = nil
                }
            }
        }
    }

    init(isLoading: Bool = false, alertMessage: String? = nil, toastMessage: String? = nil) {
        self.isLoading = isLoading
        self.alertMessage = alertMessage
        self.toastMessage = toastMessage
    }
    
    @MainActor
    func setLoading(value: Bool) {
        self.isLoading = value
    }
    
    @MainActor
    func setToastMessage(value: String?) {
        self.toastMessage = value
    }

    @MainActor
    func setAlertMessage(error: Error?) {
        if let error {
        #if EW
            if let ewException = error as? EmbeddedWalletException {
                self.alertMessage = ewException.description
            } else {
                setError(error: error)
            }
        #else
            setError(error: error)
        #endif
        } else {
            self.alertMessage = nil
        }
    }
    
    @MainActor
    private func setError(error: Error?) {
        if let error {
            if let ewException = error as? CustomError {
                self.alertMessage = ewException.description
            } else {
                self.alertMessage = error.localizedDescription
            }
        } else {
            self.alertMessage = nil
        }
    }

}

struct SpinnerView: View {
    var body: some View {
        VStack {
            ProgressView()
        }
    }
}

struct SpinnerViewContainer<Content: View>: View {
    @StateObject var loadingManager = LoadingManager()
    @ViewBuilder var content: Content
    @State var isSpinnerPresenting: Bool = false
    
    var body: some View {
        ZStack {
            content
            VStack {
                BottomAlertsContainer()
                Spacer()
            }
        }
        .environmentObject(loadingManager)
        .overlay {
            Group {
                Color.black.opacity(0.3)
                ProgressView()
            }
            .opacity(loadingManager.isLoading ? 1 : 0)
        }
        .animation(.default, value: loadingManager.isLoading)
        .animation(.default, value: loadingManager.alertMessage)
        .animation(.default, value: loadingManager.toastMessage)
    }
}

#Preview {
    VStack {
        SpinnerViewContainer() {
            Text("Hello world")
        }
    }
}
