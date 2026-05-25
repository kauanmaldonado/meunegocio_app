//
//  ImageSourcePicker.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 14/07/25.
//

import SwiftUI

enum ImageSourceType {
    case camera, photoLibrary
}

struct ImageSourcePicker: View {
    
    var onSelect: (ImageSourceType) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Selecionar Imagem")
                .font(.headline)
                .padding(.top)
                .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))

            Button(action: {
                onSelect(.photoLibrary)
                dismiss()
            }) {
                Label("Escolher da Galeria", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(Color.colorF3F4F6)
                    .background(Color(red: 0.10, green: 0.15, blue: 0.25))
                    .cornerRadius(12)
            }

            Button(action: {
                onSelect(.camera)
                dismiss()
            }) {
                Label("Abrir Câmera", systemImage: "camera")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(Color.colorF3F4F6)
                    .background(Color(red: 0.10, green: 0.15, blue: 0.25))
                    .cornerRadius(12)
            }

            Button(action: {
                dismiss()
            }) {
                Text("Cancelar")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
        .cornerRadius(20)
        .presentationDetents([.fraction(0.35)])
        .presentationDragIndicator(.visible)
    }
}
