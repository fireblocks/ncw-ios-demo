//
//  Extensions.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 03/01/2024.
//

import Foundation
import SwiftUI
import UIKit

extension View {
    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}

class GenericDecoder {
    static func decode<T: Codable>(data: Data) throws -> T? {
        return try JSONDecoder().decode(T.self, from: data)
    }

    static func decode<T: Codable>(dictionary: Any?) -> T? {
       guard let dictionary = dictionary as? [String: Any] else { return nil }
       var result: T?
       do {
           if let data = try? JSONSerialization.data(withJSONObject: dictionary) {
               result = try JSONDecoder().decode(T.self, from: data)
           }

       } catch {
           //print(error)
       }
       return result
   }
}

extension UIImage {
        var averageColor: Color {
            guard let inputImage = CIImage(image: self) else { return .clear }
           let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

            guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return .clear }
            guard let outputImage = filter.outputImage else { return .clear }

           var bitmap = [UInt8](repeating: 0, count: 4)
           let context = CIContext(options: [.workingColorSpace: kCFNull!])
           context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
            return Color(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, opacity: CGFloat(bitmap[3]) / 255)
       }
}

extension Text {
    func placeholderHeader(height: Double = 72, cornerRadius: Int = 16) -> some View {
        self.padding()
        .font(.b2)
        .frame(width: height, height: height)
        .foregroundStyle(AssetsColors.gray3.color())
        .background(.white, in: .rect(cornerRadius: 16))
    }

}

extension String {
    func iso8601Date() -> String? {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

        let updatedAt = dateFormatter.date(from: self) // "Jun 5, 2016, 4:56 PM"
        return updatedAt?.mediumFormat()
    }
}
//extension EnvironmentValues {
//    @Entry var ewManager: EWManagerProtocol = EWManager.shared
//}

