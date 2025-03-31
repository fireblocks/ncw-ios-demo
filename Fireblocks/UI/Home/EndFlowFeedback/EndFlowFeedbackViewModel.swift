//
//  EndFlowFeedbackViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 16/01/2024.
//

import Foundation
import UIKit
import SwiftUI

extension EndFlowFeedbackView {
    
    class ViewModel: ObservableObject, Hashable {
        static func == (lhs: EndFlowFeedbackView.ViewModel, rhs: EndFlowFeedbackView.ViewModel) -> Bool {
            return lhs.navigationBarTitle == rhs.navigationBarTitle
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(navigationBarTitle)
        }

        var icon: String?
        var title: String?
        var subTitle: String?
        
        var navigationBarTitle: String
        
        var buttonIcon: UIImage?
        var buttonTitle: String?
        var actionButton: (() -> ())?
        
        var rightToolbarItemIcon: String?
        var rightToolbarItemAction: (() -> ())?
        var didFail = false
        var canGoBack: Bool = true
        var items: [URL] = []
        
        var content: AnyView?
        
        init(icon: String? = nil, title: String? = nil, subTitle: String? = nil, navigationBarTitle: String = "", buttonIcon: UIImage? = nil, buttonTitle: String? = nil, actionButton: (() -> Void)? = nil, rightToolbarItemIcon: String? = nil, rightToolbarItemAction: (() -> ())? = nil, didFail: Bool = false, canGoBack: Bool = true, content: AnyView? = nil) {
            self.icon = icon
            self.title = title
            self.subTitle = subTitle
            self.didFail = didFail
            self.canGoBack = canGoBack
            
            self.navigationBarTitle = navigationBarTitle
            self.buttonIcon = buttonIcon
            self.buttonTitle = buttonTitle
            self.actionButton = actionButton
            
            self.rightToolbarItemIcon = rightToolbarItemIcon
            self.rightToolbarItemAction = rightToolbarItemAction
            self.content = content
            
            if let fireblocksLogsURL = FireblocksManager.shared.getURLForLogFiles() {
                items.append(fireblocksLogsURL)
            }
            if let appLogoURL = AppLoggerManager.shared.logger()?.getURLForLogFiles() {
                items.append(appLogoURL)
            }

        }
        
        func shareLogs() {
            NotificationCenter.default.post(name: Notification.Name("sendLogs"), object: nil, userInfo: nil)
        }
    }
    
}
