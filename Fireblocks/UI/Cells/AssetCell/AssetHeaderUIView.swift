//
//  AssetHeaderUIView.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 15/08/2023.
//

import UIKit

@objc protocol AssetHeaderDelegate: AnyObject {
    @objc func sendButtonTapped()
    @objc func receiveButtonTapped()
    @objc func plusButtonTapped()
}

class AssetHeaderUIView: UIView {
    
    private static let cornerRadius: CGFloat = 16.0
    private static let buttonHeight: CGFloat = 50.0
    private static let refreshButtonSize: CGFloat = 50.0
    private static let smallPadding: CGFloat = 8.0
    private static let defaultPadding: CGFloat = 16.0
    private static let bigPadding: CGFloat = 40.0
    
    private weak var delegate: AssetHeaderDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Roboto", size: 16)
        label.textColor = AssetsColors.white.getColor()
        label.text = "Balance"
        return label
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Roboto-Bold", size: 32)
        label.textColor = AssetsColors.white.getColor()
        return label
    }()
    
    private let sendButton: AppActionBotton = {
        let button = AppActionBotton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.config(title: "Send", image: AssetsIcons.send.getIcon(), style: .Primary)
        return button
    }()
    
    private let receiveButton: AppActionBotton = {
        let button = AppActionBotton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.config(title: "Receive", image: AssetsIcons.receive.getIcon(), style: .Secondary)
        return button
    }()
    
    private let assetsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = AssetsColors.white.getColor()
        label.text = "Assets"
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.setImage(AssetsIcons.plus.getIcon(), for: .normal)
        button.tintColor = AssetsColors.white.getColor()
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setCurrenBalance(_ balance: String) {
        balanceLabel.text = balance
    }
    
    func setDelegate(_ delegate: AssetHeaderDelegate) {
        self.delegate = delegate
    }
    
    func isButtonsEnabled(_ isEnabled: Bool) {
        sendButton.isEnabled = isEnabled
        receiveButton.isEnabled = isEnabled
    }
    
    private func setupUI() {
        initTitleLabel()
        initBalanceLabel()
        initSendButton()
        initReceiveButton()
        initPlusButton()
        initAssetsTitleLabel()
        addTargetToButtons()
    }
    
    private func initTitleLabel() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AssetHeaderUIView.smallPadding),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
        ])
    }
    
    private func initBalanceLabel() {
        addSubview(balanceLabel)
        NSLayoutConstraint.activate([
            balanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AssetHeaderUIView.smallPadding),
            balanceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: AssetHeaderUIView.smallPadding),
        ])
    }
    
    private func initSendButton() {
        addSubview(sendButton)
        NSLayoutConstraint.activate([
            sendButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AssetHeaderUIView.smallPadding),
            sendButton.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: AssetHeaderUIView.bigPadding),
            sendButton.heightAnchor.constraint(equalToConstant: AssetHeaderUIView.buttonHeight)
        ])
    }
    
    private func initReceiveButton() {
        addSubview(receiveButton)
        NSLayoutConstraint.activate([
            receiveButton.leadingAnchor .constraint(equalTo: sendButton.trailingAnchor, constant: AssetHeaderUIView.smallPadding),
            receiveButton.topAnchor.constraint(equalTo: sendButton.topAnchor),
            receiveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AssetHeaderUIView.smallPadding),
            receiveButton.bottomAnchor.constraint(equalTo: sendButton.bottomAnchor),
            receiveButton.widthAnchor.constraint(equalTo: sendButton.widthAnchor)
        ])
    }
    
    private func initPlusButton() {
        addSubview(plusButton)
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: AssetHeaderUIView.bigPadding),
            plusButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            plusButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: AssetHeaderUIView.smallPadding),
            plusButton.widthAnchor.constraint(equalToConstant: AssetHeaderUIView.buttonHeight),
            plusButton.heightAnchor.constraint(equalToConstant: AssetHeaderUIView.buttonHeight)
        ])
    }
    
    private func initAssetsTitleLabel() {
        addSubview(assetsLabel)
        NSLayoutConstraint.activate([
            assetsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AssetHeaderUIView.smallPadding),
            assetsLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor)
        ])
    }
    
    private func addTargetToButtons() {
        sendButton.addTarget(nil, action: #selector(delegate?.sendButtonTapped), for: .touchUpInside)
        receiveButton.addTarget(nil, action: #selector(delegate?.receiveButtonTapped), for: .touchUpInside)
        plusButton.addTarget(nil, action: #selector(delegate?.plusButtonTapped), for: .touchUpInside)
    }
}
