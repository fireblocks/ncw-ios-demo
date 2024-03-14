//
//  GenerateKeysSucceeded.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import SwiftUI

struct GenerateKeysSucceeded: View {
    @EnvironmentObject var appRootManager: AppRootManager
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack(spacing: 0) {
            EndFlowFeedbackView(viewModel: EndFlowFeedbackView.ViewModel(icon: AssetsIcons.generateSuccess.rawValue, subTitle: "You’ve successfully created your keys! Next, create a key backup to make sure you never lose key access.", navigationBarTitle: LocalizableStrings.didGenerateMPCKeysSuccessTitle, buttonTitle: LocalizableStrings.createKeyBackup, actionButton: {
                path.append(NavigationTypes.Backup(true))
            }, rightToolbarItemIcon: AssetsIcons.settings.rawValue, rightToolbarItemAction: {
                path.append(NavigationTypes.Settings)
            }), content: nil)
            Button {
                appRootManager.currentRoot = .assets
            } label: {
                HStack {
                    Text(LocalizableStrings.illDoThisLater)
                        .font(.body1)
                }
                .padding(16)
                .contentShape(Rectangle())
                
            }
            .buttonStyle(.borderless)
            .frame(maxWidth: .infinity)
            .foregroundStyle(AssetsColors.primaryBlue.color())
            .cornerRadius(16)

        }
    }
}

//#Preview {
//    GenerateKeysSucceeded()
//}
