//
//  BottomAlertsContainer.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 02/03/2025.
//

import SwiftUI

@Observable
class AlertsManager {
    var alertMessage: String? {
        didSet {
            if alertMessage != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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


    @MainActor
    func setToastMessage(value: String?) {
        self.toastMessage = value
    }

    @MainActor
    func setAlertMessage(value: String?) {
        self.alertMessage = value
    }

}

struct BottomAlertsContainer: View {
    @Environment(LoadingManager.self) var loadingManager

    var body: some View {
        ZStack {
            AlertBannerView(message: loadingManager.alertMessage)
                .padding()
                .frame(height: loadingManager.alertMessage == nil ? 0 : nil)
                .animation(.default, value: loadingManager.alertMessage)
                .clipped()
            BottomBanner(message: loadingManager.toastMessage)
                .padding()
                .frame(height: loadingManager.toastMessage == nil ? 0 : nil)
                .animation(.default, value: loadingManager.toastMessage)
                .clipped()
        }
        .background(Color.black)
    }
}

#Preview {
    VStack {
        Spacer()
        BottomAlertsContainer()
            .environment(LoadingManager(alertMessage: "Alert\nAlert\nAlert"))
        BottomAlertsContainer()
            .environment(LoadingManager(toastMessage: "Copied"))
        Spacer()
    }
    .background(.green)
}
