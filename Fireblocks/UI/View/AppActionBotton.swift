//
//  CustomButton.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 13/06/2023.
//

import UIKit

enum ButtonStyle {
    case Primary
    case Secondary
    case Transparent
    case Disabled

    var colors: (primaryBackgountColor: UIColor,
                 tappedBackgountColor: UIColor,
                 disabledBackgountColor: UIColor,
                 primaryTitleColor: UIColor,
                 disabledTitleColor: UIColor) {
        switch self {
        case .Primary:
            return (AssetsColors.primaryBlue.getColor(),
                    AssetsColors.tapBlue.getColor(),
                    AssetsColors.darkerBlue.getColor(),
                    AssetsColors.white.getColor(),
                    AssetsColors.gray3.getColor())
        case .Secondary:
            return (AssetsColors.gray1.getColor(),
                    AssetsColors.gray2.getColor(),
                    AssetsColors.disableGray.getColor(),
                    AssetsColors.white.getColor(),
                    AssetsColors.gray3.getColor())
        case .Transparent:
            return (.clear,
                    .clear,
                    .clear,
                    AssetsColors.lightBlue.getColor(),
                    AssetsColors.gray3.getColor())
        case .Disabled:
            return (AssetsColors.primaryBlue.getColor(),
                    AssetsColors.tapBlue.getColor(),
                    AssetsColors.darkerBlue.getColor(),
                    AssetsColors.white.getColor(),
                    AssetsColors.gray3.getColor())
        }
    }
}


class AppActionBotton: UIButton {
    
    private var buttonTitle: String = ""
    private var style: ButtonStyle = .Primary
    
    private var spacing: CGFloat = 8
    private var cornerRadius: CGFloat = 16
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configButton()
    }
    
    func config(title: String, image: UIImage? = nil, style: ButtonStyle) {
        self.style = style
        buttonTitle = title
        configButton()
        
        if let image = image {
            addImage(image)
        }
    }
    
    
    private func configButton(){
        
        if #available(iOS 15.0, *) {
            configuration = UIButton.Configuration.filled()
            updateConfiguration()
        } else {
            addTitle()
            setBackgroundImage(imageWithColor(style.colors.primaryBackgountColor), for: .normal)
            setBackgroundImage(imageWithColor(style.colors.tappedBackgountColor), for: .highlighted)
            setBackgroundImage(imageWithColor(style.colors.disabledBackgountColor), for: .disabled)
            
            setTitleColor(style.colors.primaryTitleColor, for: .normal)
            setTitleColor(style.colors.disabledTitleColor, for: .disabled)
            
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
        }
    }
    
    
    private func addTitle(){
        setTitle(buttonTitle, for: .normal)
    }
    
    private func addImage(_ image: UIImage){
        let primaryImage = prepareImage(image, color: style.colors.primaryTitleColor)
        let disabledImage = prepareImage(image, color: style.colors.disabledTitleColor)
        setImage(primaryImage, for: .normal)
        setImage(disabledImage, for: .disabled)
        
        if #available(iOS 15.0, *) {
            configuration?.imagePadding = spacing
        } else {
            addSpacer(with: 10)
        }
    }
    
    private func prepareImage(_ image: UIImage, color: UIColor?) -> UIImage? {
        guard let color = color else { return nil }
        if image.renderingMode == .alwaysTemplate {
            let tintedColor = color
            
            UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
            tintedColor.set()
            image.draw(in: CGRect(origin: .zero, size: image.size))
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return finalImage ?? image
        }
        
        return image
    }
    
    private func imageWithColor(_ color: UIColor?) -> UIImage? {
        guard let color = color else { return nil }
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    
    @available(iOS 15.0, *)
    override func updateConfiguration() {
        guard let configuration = configuration else {
            return
        }
        
        
        var updatedConfiguration = configuration
        updatedConfiguration.title = buttonTitle
        var background = UIButton.Configuration.filled().background
        background.cornerRadius = 16
        
        let backgroundColor: UIColor
        
        switch self.state {
        case .normal:
            backgroundColor = style.colors.primaryBackgountColor
            updatedConfiguration.baseForegroundColor = style.colors.primaryTitleColor
        case .highlighted:
            backgroundColor = style.colors.tappedBackgountColor
            updatedConfiguration.baseForegroundColor = style.colors.primaryTitleColor
        case .disabled:
            backgroundColor = style.colors.disabledBackgountColor
            updatedConfiguration.baseForegroundColor = style.colors.disabledTitleColor
        default:
            backgroundColor = UIColor.white
        }
        
        background.backgroundColorTransformer = UIConfigurationColorTransformer { color in
            return backgroundColor
        }
        
        updatedConfiguration.background = background
        self.configuration = updatedConfiguration
    }
}
