//
//  ActivityIndicator.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 09/07/2023.
//

import UIKit
import NVActivityIndicatorView

class ActivityIndicator {
    
    static let shared = ActivityIndicator()
    private static let activityIndicatorSize: CGFloat = 60
    
    private var activityIndicator = NVActivityIndicatorView(
        frame: CGRect(x: 0, y: 0, width: activityIndicatorSize, height: activityIndicatorSize),
        type: .circleStrokeSpin,
        color: AssetsColors.primaryBlue.getColor(),
        padding: nil
    )
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = AssetsColors.white.getColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: "Figtree-Medium", size: 16)
        return label
    }()
    
    private var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = AssetsColors.black.getColor().withAlphaComponent(0.8)
        return view
    }()
    
    private init() {}
    
    func showLoadingIndicator(in view: UIView, message: String? = nil, isBackgroundEnabled: Bool) {
        if isBackgroundEnabled {
            addBackgroundView(view)
        }
        
        addActivityIndicator(view)
        addTitleView(view, message)
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        backgroundView.removeFromSuperview()
        titleLabel.removeFromSuperview()
    }
    
    private func addActivityIndicator(_ view: UIView) {
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    private func addBackgroundView(_ view: UIView) {
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func addTitleView(_ view: UIView, _ message: String?) {
        if let message = message {
            view.addSubview(titleLabel)
            titleLabel.text = message
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
    }
}
