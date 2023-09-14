//
//  TabBarViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 15/06/2023.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    var toastMessage: String = ""
//MARK: - PROPERTIES
    var subviewControllers: [UIViewController] = []
//MARK: - LIFECYCLE Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: true)
        initSubviewControllers()
        configTabBarView()
        
        self.setViewControllers(subviewControllers,animated: true)
        self.selectedIndex = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isShowToast()
    }
    
//MARK: - FUNCTIONS
    private func initSubviewControllers(){
        typealias TabBarItem = (viewController: UIViewController, image: UIImage, name: String)
        let viewControllers: [TabBarItem] = [ (AssetListViewController(), AssetsIcons.wallet.getIcon(), "Assets"),
                                              (TransfersViewController(), AssetsIcons.transfer.getIcon(), "Transfers")]
        
        setupNavButtons()
        for (index,item) in viewControllers.enumerated() {
            let viewController = item.viewController
            let _ = viewController.view
            let tabImage = item.image
            viewController.tabBarItem = UITabBarItem(title: item.name, image: tabImage, tag: index)
            subviewControllers.append(viewController)
        }
    }
    
    private func setupNavButtons() {
        let barButtonITem = UIBarButtonItem(title: "Welcome to Bitvault", style: .plain, target: self, action: nil)
        barButtonITem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font:UIFont.init(name:"Roboto", size:20.0)!], for: .disabled)
        barButtonITem.isEnabled = false
        navigationItem.leftBarButtonItems = [barButtonITem]
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(settingsTapped))]
    }
    
    @objc func settingsTapped(){
        let vc = SettingsViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func configTabBarView(){
        let blackColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.tabBar.barTintColor = blackColor
        self.tabBar.tintColor = AssetsColors.primaryBlue.getColor()

        let normalColor = AssetsColors.gray4.getColor()
        let selectedColor = AssetsColors.white.getColor()
        let imageTintColor = AssetsColors.alert.getColor()
        let font = UIFont(name: "Roboto", size: 14) ?? UIFont.systemFont(ofSize: 14)
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: normalColor,
            .font: font
        ]
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [ .foregroundColor: selectedColor]
        for item in subviewControllers {
            item.tabBarItem.setTitleTextAttributes(normalTextAttributes, for: .normal)
            item.tabBarItem.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        }

    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
    
    private func isShowToast() {
        if toastMessage.isEmpty {
            return
        }
        showToast(toastMessage)
        toastMessage = ""
    }
}
