//
//  EndFlowFeedbackViewModel.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 16/01/2024.
//

import Foundation
import UIKit

extension EndFlowFeedbackView {
    
    class ViewModel: ObservableObject {
        var icon: String?
        var title: String?
        var subTitle: String?
        
        var navigationBarTitle: String
        
        var buttonIcon: UIImage?
        var buttonTitle: String?
        var actionButton: (() -> ())?
        
        var rightToolbarItemIcon: String?
        var rightToolbarItemAction: (() -> ())?
        
        init(icon: String? = nil, title: String? = nil, subTitle: String? = nil, navigationBarTitle: String = "", buttonIcon: UIImage? = nil, buttonTitle: String? = nil, actionButton: (() -> Void)? = nil, rightToolbarItemIcon: String? = nil, rightToolbarItemAction: (() -> ())? = nil) {
            self.icon = icon
            self.title = title
            self.subTitle = subTitle
            
            self.navigationBarTitle = navigationBarTitle
            self.buttonIcon = buttonIcon
            self.buttonTitle = buttonTitle
            self.actionButton = actionButton
            
            self.rightToolbarItemIcon = rightToolbarItemIcon
            self.rightToolbarItemAction = rightToolbarItemAction
        }
    }
    
}
