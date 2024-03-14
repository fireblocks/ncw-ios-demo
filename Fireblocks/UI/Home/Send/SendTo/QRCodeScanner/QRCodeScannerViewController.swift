//
//  QRCodeScannerViewController.swift
//  Fireblocks
//
//  Created by Fireblocks Ltd. on 03/07/2023.
//

import UIKit
import AVFoundation

protocol QRCodeScannerViewControllerDelegate: AnyObject {
    func gotAddress(address: String)
}

class QRCodeScannerViewController: UIViewController{
    
//MARK: - PROPERTIES
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var scanningAreaView: UIView!
    @IBOutlet weak var backgroundCameraView: UIView!
    
    weak var delegate: QRCodeScannerViewControllerDelegate?
    
    var captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
//MARK: - LIFECYCLE Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCaptureSession()
        startScanning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = CGRect(origin: .zero, size: backgroundCameraView.bounds.size)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
//MARK: - FUNCTIONS
    private func configButtons(){
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(handleCloseTap))]
        self.navigationItem.title = "Scan QR"
    }
    
    @objc private func handleCloseTap() {
        navigateBack()
    }
    
    
    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Failed to get video capture device")
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            print("Failed to create video capture input")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Failed to add metadata output")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(origin: .zero, size: backgroundCameraView.bounds.size)
        previewLayer.videoGravity = .resizeAspectFill
        backgroundCameraView.layer.addSublayer(previewLayer)
    }
    
    private func startScanning() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    private func stopScanning() {
        captureSession.stopRunning()
    }
    
    private func navigateBack(){
        navigationController?.popViewController(animated: true)
    }
}


//MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRCodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue,
              let videoPreviewLayer = previewLayer else {
            return
        }
        
        let transformedMetadataObject = videoPreviewLayer.transformedMetadataObject(for: metadataObject)
        if isQRCodeReceivedFromScanningArea(metadataObject: transformedMetadataObject) {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.navigationController?.popViewController(animated: true, completion: {
                self.delegate?.gotAddress(address: stringValue)
            })
        }
    }
    
    private func isQRCodeReceivedFromScanningArea(metadataObject: AVMetadataObject?) -> Bool {
        guard let transformedBounds = metadataObject?.bounds else {
            return false
        }
        
        let greenRectangleFrame = scanningAreaView.frame
        
        let transformedTopLeft = CGPoint(x: transformedBounds.minX, y: transformedBounds.minY)
        let transformedTopRight = CGPoint(x: transformedBounds.maxX, y: transformedBounds.minY)
        let transformedBottomLeft = CGPoint(x: transformedBounds.minX, y: transformedBounds.maxY)
        let transformedBottomRight = CGPoint(x: transformedBounds.maxX, y: transformedBounds.maxY)
        
        if greenRectangleFrame.contains(transformedTopLeft) &&
            greenRectangleFrame.contains(transformedTopRight) &&
            greenRectangleFrame.contains(transformedBottomLeft) &&
            greenRectangleFrame.contains(transformedBottomRight) {
            return true
        }
        
        return false
    }
}
