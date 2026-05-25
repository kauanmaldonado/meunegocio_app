//
//  QRCodeScannerDelegate.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 20/03/25.
//

import SwiftUI
import AVKit

class QRCodeScannerDelegate: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {

    var onCodeDetected: ((String) -> Void)?

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print("🎯 Delegate chamado!")
        if let metaObject = metadataObjects.first {
            guard let readableObject = metaObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let scannedCode = readableObject.stringValue else { return }
            print("📦 Código lido: \(scannedCode)")
            onCodeDetected?(scannedCode)
        }
    }
}
