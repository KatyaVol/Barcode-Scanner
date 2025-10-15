//
//  ScannerView.swift
//  BarcodeScanner
//
//  Created by Ekaterina Volobueva on 14.10.2025.
//

import SwiftUI

struct ScannerView: UIViewControllerRepresentable {
    
    @Binding var scannedCode: String
    @Binding var alertItem: AlertItem?
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        ScannerViewController(scannerDelegate: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scannerView: self)
    }
    
    final class Coordinator: NSObject, ScannerViewControllerDelegate {
        
        private let scannerView: ScannerView
        
        init(scannerView: ScannerView) {
            self.scannerView = scannerView
        }
        
        func didFind(barcode: String) {
            DispatchQueue.main.async {
                self.scannerView.scannedCode = barcode
            }
        }

        func didFail(with error: CameraError) {
            DispatchQueue.main.async {
                switch error {
                case .invalidDeviceInput:
                    self.scannerView.alertItem = AlertContext.invalidDeviceInput
                case .invalidScannedValue:
                    self.scannerView.alertItem = AlertContext.invalidScannedType
                }
            }
        }
    }

}
