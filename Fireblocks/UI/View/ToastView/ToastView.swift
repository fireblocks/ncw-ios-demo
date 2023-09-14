//
//  ToastView.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 23/07/2023.
//

import UIKit

enum ToastViewType {
    case success
    case failed
    
    func getImage() -> UIImage {
        switch self {
        case .success:
            return AssetsIcons.checkMark.getIcon()
        case .failed:
            return AssetsIcons.close.getIcon()
        }
    }
}

class ToastView: UIView {
    
    private static let paddingFromEdge: CGFloat = 16
    private static let cornerRadius: CGFloat = 10
    private static let alpha: CGFloat = 0.8
    private static let imageSize: CGFloat = 0.8
    
    private let imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.tintColor = AssetsColors.white.getColor()
        imageView.image = AssetsIcons.checkMark.getIcon()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = AssetsColors.white.getColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = LocalizableStrings.copied
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setMessage(_ message: String) {
        label.text = message
    }
    
    func setImage(type: ToastViewType) {
        imageView.image = type.getImage()
    }
    
    private func setupUI() {
        initBackground()
        initImageView()
        initLabel()
    }
    
    private func initBackground() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AssetsColors.gray1.getColor().withAlphaComponent(ToastView.alpha)
        layer.cornerRadius = ToastView.cornerRadius
    }
    
    private func initImageView() {
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ToastView.paddingFromEdge),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: ToastView.paddingFromEdge),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ToastView.paddingFromEdge),
        ])
    }
    
    private func initLabel() {
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ToastView.paddingFromEdge),
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8)
        ])
    }
}
