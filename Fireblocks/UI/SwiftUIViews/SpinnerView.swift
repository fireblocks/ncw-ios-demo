//
//  SpinnerView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI

class LoadingManager: ObservableObject {
    @Published var isLoading: Bool = false
    
    @MainActor
    func setLoading(value: Bool) {
        self.isLoading = value
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
        content
            .environmentObject(loadingManager)
            .fullScreenCover(isPresented: $isSpinnerPresenting) {
                SpinnerView()
                    .presentationBackground(Color.black.opacity(0.5))
            }
            .onChange(of: loadingManager.isLoading) { newValue in
                withoutAnimation {
                    isSpinnerPresenting = newValue
                }
            }
    }
}

#Preview {
    VStack {
        SpinnerViewContainer() {
            Text("Hello world")
        }
    }
}
