//
//  Spinner.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 11/03/2024.
//

import SwiftUI

struct Spinner: View {
    @State var degrees = 0.0
    var body: some View {
        Image(.spinner)
            .rotationEffect(.degrees(degrees))
            .onAppear() {
                withAnimation(.linear(duration: 1).speed(0.5).repeatForever(autoreverses: false)) {
                    degrees = 360.0
                }
            }
    }
}

#Preview {
    Spinner()
}
