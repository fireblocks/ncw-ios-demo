//
//  CacheManager.swift
//  Fireblocks
//
//  Created by Dudi Shani-Gabay on 27/02/2025.
//

import Foundation
import UIKit

class ImageData {
    let image: UIImage
    let date: Date
    
    init(image: UIImage, date: Date) {
        self.image = image
        self.date = date
    }
    
    func isExpired() -> Bool {
        return Date().timeIntervalSince(date) > 60 * 60 * 24 * 30
    }
}

class CacheManager {
    static let shared = CacheManager()
    
    private let imageCache = NSCache<AnyObject, AnyObject>()

    func addImage(url: URL, image: UIImage) {
        imageCache.setObject(ImageData(image: image, date: Date()) as AnyObject, forKey: url as AnyObject)
    }
    
    func getImage(url: URL) -> UIImage? {
        if let imageData: ImageData = imageCache.object(forKey: url as AnyObject) as? ImageData {
            if imageData.isExpired() {
                return nil
            }
            
            return imageData.image
        }
        
        return nil
    }
}
