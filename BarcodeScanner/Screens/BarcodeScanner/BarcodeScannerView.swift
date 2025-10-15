//
//  ContentView.swift
//  BarcodeScanner
//
//  Created by Ekaterina Volobueva on 13.10.2025.
//

import SwiftUI

struct BarcodeScannerView: View {
    
    @StateObject private var viewModel = BarcodeScannerViewModel()
    
    var body: some View {
        NavigationStack {
            scannerContainer
                .navigationTitle("Barcode Scanner")
                .alert(item: $viewModel.alertItem) { alertItem in
                    Alert(
                        title: Text(alertItem.title),
                        message: Text(alertItem.message),
                        dismissButton: alertItem.dismissButton
                    )
                }
        }
    }
    
    private var scannerContainer: some View {
        VStack {
            ScannerView(scannedCode: $viewModel.scannedCode, alertItem: $viewModel.alertItem)
                .frame(maxWidth: .infinity, maxHeight: 300)

            Spacer().frame(height: 60)
            
            Label("Scanned barcode:", systemImage: "barcode.viewfinder")
                .font(.title)
            
            Text(viewModel.statusText)
                .bold()
                .font(.largeTitle)
                .foregroundColor(viewModel.statusTextColor)
                .padding()
        }
    }
}

#Preview {
    BarcodeScannerView()
}
