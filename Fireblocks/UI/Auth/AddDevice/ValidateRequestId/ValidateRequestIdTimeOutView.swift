//
//  ValidateRequestIdTimeOutView.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 16/01/2024.
//

import SwiftUI

struct ValidateRequestIdTimeOutView: View {
    var body: some View {
        VStack {
            Text("Why did this happen?")
                .font(.b1)
                .padding(24)
            VStack(spacing: 16) {
                HStack {
                    Text("\u{2022} ")
                    Text("The QR code expired\nScan the QR code within 3 minutes.")
                    Spacer()
                }
                .font(.b2)

                HStack {
                    Text("\u{2022} ")
                    Text("Embedded wallet couldn’t connect\nCheck your connection and try again.")
                    Spacer()
                }
                .font(.b2)

            }
            .padding(.horizontal)
            .padding(.bottom, 24)


        }
        .background(AssetsColors.gray1.color())
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ValidateRequestIdTimeOutView()    
}
