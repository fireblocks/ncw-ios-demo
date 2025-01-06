//
//  LaunchViewModel.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 05/01/2025.
//

import SwiftUI
import Combine

extension LaunchView {
    class ViewModel: ObservableObject {
        @Published var didTapLetsGo = false
    }
}
