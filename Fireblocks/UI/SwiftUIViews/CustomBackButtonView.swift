//
//  CustomBackButtonView.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI

struct CustomBackButtonView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(.backButton)
        }
    }
}

#Preview {
    CustomBackButtonView()
}
