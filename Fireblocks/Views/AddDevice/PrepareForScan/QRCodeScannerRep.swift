//
//  QRCodeScannerRep.swift
//  NCW-sandbox
//
//  Created by Dudi Shani-Gabay on 14/03/2024.
//

import Foundation
import SwiftUI

struct QRCodeScannerRep: UIViewControllerRepresentable, Hashable {
    let vc = QRCodeScannerViewController(nibName: "QRCodeScannerViewController", bundle: nil)
    typealias UIViewControllerType = UIViewController
    
    init(delegate: QRCodeScannerViewControllerDelegate) {
        vc.delegate = delegate
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        //
    }
    
}
