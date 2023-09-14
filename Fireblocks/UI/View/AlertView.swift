//
//  WarningView.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 20/07/2023.
//

import UIKit

enum AlertViewType {
    case error
    case warning
    
    var color: UIColor {
        switch self {
        case .error:
            return AssetsColors.alert.getColor()
        case .warning:
            return AssetsColors.warning.getColor()
        }
    }
    
    var image: UIImage {
        switch self {
        case .error:
            return AssetsIcons.error.getIcon()
        case .warning:
            return AssetsIcons.warning.getIcon()
        }
    }
}

class AlertView: UIView {
    
    private static let backgroundAlpha: CGFloat = 0.2
    private static let cornerRadius: CGFloat = 16
    private static let smallPadding: CGFloat = 4
    private static let defaultPadding: CGFloat = 12
    private static let bigPadding: CGFloat = 16
    private static let borderWidth: CGFloat = 1
    private static let imageSize: CGFloat = 20
    private static let labelSize: CGFloat = 17
    
    private let alertType = AlertViewType.error
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AssetsColors.white.getColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: labelSize)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = AssetsColors.white.getColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: labelSize)
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        initBackground()
        initImageView()
        initTitle()
        initDescription()
    }
    
    func setMessage(
        title: String = "",
        description: String,
        alertType: AlertViewType = AlertViewType.error
    ) {
        self.titleLabel.text = title
        self.descriptionLabel.text = description
        updateAlertType(alertType)
    }
    
    private func initBackground() {
        backgroundColor = alertType.color.withAlphaComponent(AlertView.backgroundAlpha)
        layer.cornerRadius = AlertView.cornerRadius
        addBorder(color: alertType.color, width: AlertView.borderWidth)
    }
    
    private func initImageView() {
        imageView.image = alertType.image
        imageView.tintColor = alertType.color
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: AlertView.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: AlertView.imageSize),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AlertView.bigPadding),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: AlertView.bigPadding)
        ])
    }
    
    private func initTitle() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: AlertView.defaultPadding),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: AlertView.bigPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AlertView.bigPadding),
        ])
    }
    
    private func initDescription() {
        addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: AlertView.defaultPadding),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AlertView.bigPadding),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -AlertView.bigPadding)
        ])
    }
    
    private func updateAlertType(_ alertType: AlertViewType) {
        backgroundColor = alertType.color.withAlphaComponent(AlertView.backgroundAlpha)
        addBorder(color: alertType.color, width: AlertView.borderWidth)
        imageView.image = alertType.image
        imageView.tintColor = alertType.color
    }
}
