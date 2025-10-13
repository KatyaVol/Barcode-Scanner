//
//  ScannerViewController.swift
//  BarcodeScanner
//
//  Created by Ekaterina Volobueva on 13.10.2025.
//

import AVFoundation
import UIKit

enum CameraError: String {
    case invalidDeviceInput = "Something is wrong with the camera input. We are unable to access the camera."
    case invalidScannedValue = "The value scanned is not a valid barcode. This app scans EAN-8 and EAN-13"
}

protocol ScannerViewControllerDelegate: AnyObject {
    func didFind(barcode: String)
    func didFail(with error: CameraError)
}

final class ScannerViewController: UIViewController {

    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?

    weak var scannerDelegate: ScannerViewControllerDelegate?

    init(scannerDelegate: ScannerViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.scannerDelegate = scannerDelegate
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        guard
            let videoCaptureDevice = AVCaptureDevice.default(for: .video)
        else {
            scannerDelegate?.didFail(with: .invalidDeviceInput)
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: videoCaptureDevice)
            captureSession.addInput(input)
        } catch {
            scannerDelegate?.didFail(with: .invalidDeviceInput)
            debugPrint("Failed to create AVCaptureDeviceInput: \(error)")
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13]
        } else {
            scannerDelegate?.didFail(with: .invalidDeviceInput)
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        
        guard let previewLayer else {
            scannerDelegate?.didFail(with: .invalidDeviceInput)
            return
        }
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard
            let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            let barcode = object.stringValue
        else {
            scannerDelegate?.didFail(with: .invalidScannedValue)
            return
        }
        scannerDelegate?.didFind(barcode: barcode)
    }

}
