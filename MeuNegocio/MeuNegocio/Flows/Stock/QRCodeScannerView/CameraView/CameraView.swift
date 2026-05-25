//
//  CameraView.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 20/03/25.
//

import SwiftUI
import AVKit

struct CameraView: UIViewRepresentable {

    var frameSize: CGSize
    
    @Binding var session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIViewType(frame: CGRect(origin: .zero, size: frameSize))
        view.backgroundColor = .clear
        
        let cameraLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraLayer.frame = .init(origin: .zero, size: frameSize)
        cameraLayer.videoGravity = .resizeAspectFill
        cameraLayer.masksToBounds = true

        view.layer.addSublayer(cameraLayer)
    

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.session = session
            previewLayer.frame = CGRect(origin: .zero, size: frameSize)
        }
    }
}

