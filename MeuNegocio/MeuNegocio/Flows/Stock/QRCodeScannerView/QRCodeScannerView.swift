//
//  QRCodeScannerView.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 20/03/25.
//

import SwiftUI
import AVKit

struct QRCodeScannerView: View {
    
    @Binding var scannedCode: String
    @Binding var isPresented: Bool

    @State private var session: AVCaptureSession = .init()
    @State private var qrOutput: AVCaptureMetadataOutput = .init()
    @State private var cameraPermission: Permission = .idle
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    @Environment(\.openURL) private var openURL

    private let qrDelegate = QRCodeScannerDelegate()

    var body: some View {
        NavigationStack {
            
            VStack(spacing: 8) {

                Button {
                    self.scannedCode = ""
                    self.isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(.black)
                }
                .padding(.top, 12)
                .padding(.trailing, 12)
                .frame(maxWidth: .infinity, alignment: .trailing)
                
                Spacer().frame(height: 16)

                Text("Aponte a camera para o QR Code")
                    .multilineTextAlignment(.center)
                    .frame(alignment: .center)
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.10, green: 0.15, blue: 0.25),
                            Color(red: 0.07, green: 0.10, blue: 0.15)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .font(.system(size: 30, weight: .bold))
                    .padding(.horizontal, 20)
//                    .font(.title3)
//                    .foregroundStyle(.black.opacity(0.8))
                
                Spacer().frame(height: 4)

                Text("O Scanner irá iniciar automaticamente")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.gray)
                
                Spacer(minLength: 0)
                
                GeometryReader { geometry in
                    let size = geometry.size
                    
                    ZStack {
                        
                        CameraView(frameSize: size, session: $session)

                        ForEach([0, 90, 180, 270], id: \.self) { angle in
                            CornerLine()
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(Double(angle)))
                                .offset(cornerOffset(for: angle, size: min(geometry.size.width, geometry.size.height)))
                                .background(.clear)
                        }
                    }
                    .frame(width: size.width, height: size.height)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.clear)
                }
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 30)
                
                Spacer(minLength: 15)

//                Button {
//
//                } label: {
//                    Image(systemName: "qrcode.viewfinder")
//                        .font(.largeTitle)
//                        .foregroundStyle(.gray)
//                }
                
                Spacer(minLength: 45)
                
                
            }
            .padding(15)
            .onAppear {
                checkCameraPermission()
            }
            .onDisappear {
                session.stopRunning()
                if let output = session.outputs.first(where: { $0 is AVCaptureMetadataOutput }) as? AVCaptureMetadataOutput {
                    output.setMetadataObjectsDelegate(nil, queue: .main)
                }
            }
            .alert(errorMessage, isPresented: $showError) {
                Text("")
                
                if cameraPermission == .denied {
                    Button("Settings") {
                        let settingsString = UIApplication.openSettingsURLString
                        if let settingsURL = URL(string: settingsString) {
                            openURL(settingsURL)
                        }
                    }
                    
                    Button("Cancel", role: .cancel) {
                        
                    }
                }
            }
        }
    }

    func checkCameraPermission() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermission = .approved
                setupCamera()
            case .notDetermined:
                if await AVCaptureDevice.requestAccess(for: .video) {
                    cameraPermission = .approved
                    setupCamera()
                } else {
                    cameraPermission = .denied
                }
            case .denied, .restricted:
                cameraPermission = .denied
            default: break
            }
        }
    }
    
    func setupCamera() {
        do {
            guard let device = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera],
                mediaType: .video,
                position: .back
            ).devices.first else { return }

            let input = try AVCaptureDeviceInput(device: device)

            session.beginConfiguration()

            if session.canAddInput(input) { session.addInput(input) }

            if session.canAddOutput(qrOutput) { session.addOutput(qrOutput) }

            qrOutput.setMetadataObjectsDelegate(qrDelegate, queue: .main)
            qrOutput.metadataObjectTypes = qrOutput.availableMetadataObjectTypes

            session.commitConfiguration()

            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }

            qrDelegate.onCodeDetected = { code in
                self.scannedCode = code
                self.isPresented = false
            }
        } catch {
            
        }
    }

    func presentError(_ message: String) {
        errorMessage = message
        showError.toggle()
    }
}

/// Componente para desenhar os traços nos cantos
struct CornerLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 0, y: 10))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 10, y: 0))
        
        return path
    }
}

/// Calcula o deslocamento para posicionar os traços nos cantos corretamente
private func cornerOffset(for angle: Int, size: CGFloat) -> CGSize {
    let offset = size / 2 - 20
    switch angle {
    case 0:   return CGSize(width: -offset, height: -offset) // Superior esquerdo
    case 90:  return CGSize(width: offset, height: -offset)  // Superior direito
    case 180: return CGSize(width: offset, height: offset)   // Inferior direito
    case 270: return CGSize(width: -offset, height: offset)  // Inferior esquerdo
    default:  return .zero
    }
}


#Preview {
//    QRCodeScannerView(scannedCode: scannedCode, isPresented: isPresented)
}
