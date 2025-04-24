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

@Observable
class LoadingManager {
    var isLoading: Bool = false
    var alertMessage: String? {
        didSet {
            if alertMessage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.alertMessage = nil
                }
            }
        }
    }
    
    var toastMessage: String? {
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
            setLoading(value: false)
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

struct CircularProgressView: View {
    @State private var isAnimating = false
    let size: CGFloat
    let lineWidth: CGFloat
    
    init(size: CGFloat = 60, lineWidth: CGFloat = 6) {
        self.size = size
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        VStack {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.white, lineWidth: lineWidth)
                .frame(width: size, height: size)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}


struct SpinnerViewContainer<Content: View>: View {
    var isBasic = false
    var title = ""
    @State var loadingManager = LoadingManager()
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
        .environment(loadingManager)
        .overlay {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea(.all)
                if isBasic {
                    ProgressView()
                } else {
                    VStack(spacing: 8) {
                        CircularProgressView()
                        if !title.isEmpty {
                           Text(title)
                        }
                    }
                    .padding()
                    .background(title.isEmpty ? Color.clear : Color.black.opacity(0.5), in: .rect(cornerRadius: 8))
                }
            }
            .opacity(loadingManager.isLoading ? 1 : 0)
        }
//        .animation(.default, value: loadingManager.isLoading)
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

#Preview("SpinnerView Components") {
    VStack(spacing: 40) {
        // Preview CircularProgressView with different sizes
        HStack(spacing: 30) {
            CircularProgressView(size: 18, lineWidth: 1.5)
            CircularProgressView(size: 24, lineWidth: 2) // Default
            CircularProgressView(size: 40, lineWidth: 3)
            CircularProgressView(size: 60, lineWidth: 4)
        }
        
        // Preview SpinnerViewContainer
        SpinnerViewContainer(title: "Loading wallet...") {
            VStack {
                Text("Content behind loading overlay")
                    .padding()
                Button("Show Content") {
                    // Just for visual reference
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(height: 200)
        }
        .frame(height: 200)
    }
    .padding()
}

