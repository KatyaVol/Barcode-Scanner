//
//  Alert.swift
//  BarcodeScanner
//
//  Created by Ekaterina Volobueva on 15.10.2025.
//
import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let dismissButton: Alert.Button
}

struct AlertContext {
    static let invalidDeviceInput = AlertItem(
        title: "Invalid Device input",
        message: "Something is wrong with the camera input. We are unable to access the camera.",
        dismissButton: .default(Text("OK"))
    )
    
    static let invalidScannedType = AlertItem(
        title: "Invalid Scanned Type",
        message: "The value scanned is not a valid barcode. This app scans EAN-8 and EAN-13",
        dismissButton: .default(Text("OK"))
    )
}
