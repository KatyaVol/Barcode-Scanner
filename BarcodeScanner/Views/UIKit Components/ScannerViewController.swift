//
//  ScannerViewController.swift
//  BarcodeScanner
//
//  Created by Ekaterina Volobueva on 13.10.2025.
//

import AVFoundation
import UIKit

protocol ScannerViewControllerDelegate: AnyObject {
    func didFind(barcode: String)
    func didFail(with error: CameraError)
}

final class ScannerViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    weak var scannerDelegate: ScannerViewControllerDelegate?
    
    private var hasReportedError = false
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let previewLayer else {
            if !hasReportedError {
                hasReportedError = true
                scannerDelegate?.didFail(with: .invalidDeviceInput)
            }
            return
        }
        previewLayer.frame = view.layer.bounds
        
    }
    
}

extension ScannerViewController {
    
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
        
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
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
        captureSession.stopRunning()
        scannerDelegate?.didFind(barcode: barcode)
    }
    
}
