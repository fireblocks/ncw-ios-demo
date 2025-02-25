//
//  NavigationBarLeftHeader.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 11/02/2025.
//

import SwiftUI

struct NavigationBarLeftHeader: View {
            
    var body: some View {
        HStack {
            Image("navigationBar")
            Text(Constants.navigationTitle)
                .font(.h2)
        }
    }
}


