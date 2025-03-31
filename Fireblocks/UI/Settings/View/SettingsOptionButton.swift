//
//  SettingsOptionButton.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 18/06/2023.
//

import UIKit

class SettingsOptionButton: UIButton {
    
    private let iconSize: CGFloat = 20
    private let cornerRadius: CGFloat = 16
    private let padding: CGFloat = 16
    
    private let titleView: UILabel = {
        let labelSize: CGFloat = 17
        let labelNumberOfLines = 2
        
        let label = UILabel()
        label.font = UIFont(name: "Figtree-Regular", size: labelSize)
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = labelNumberOfLines
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let disabledView: UIView = {
        let view = UIView()
        view.backgroundColor = AssetsColors.black.getColor().withAlphaComponent(0.5)
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configButton()
    }
    
    func setData(title: String, icon: AssetsIcons) {
        titleView.text = title
        iconImageView.image = icon.getIcon()
    }
    
    func disableView(){
        addSubview(disabledView)
        addDisabledViewConstraints()
    }
    
    private func configButton() {
        initMainView()
        
        addSubview(titleView)
        addTitleConstraints()
        
        addSubview(iconImageView)
        addIconConstraints()
    }
    
    private func initMainView() {
        self.backgroundColor = AssetsColors.gray1.getColor()
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
    private func addTitleConstraints() {
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: padding),
            titleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
        ])
    }
    
    private func addIconConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: titleView.topAnchor, constant: -padding / 2),
            iconImageView.widthAnchor.constraint(equalToConstant: iconSize),
            iconImageView.heightAnchor.constraint(equalToConstant: iconSize),
        ])
    }
    
    private func addDisabledViewConstraints(){
        NSLayoutConstraint.activate([
            disabledView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            disabledView.topAnchor.constraint(equalTo: self.topAnchor),
            disabledView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            disabledView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}
