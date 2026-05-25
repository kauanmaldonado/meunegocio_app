//
//  AddImageButton.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 27/03/25.
//

import SwiftUI

struct AddImageButton: View {

    @Binding var selectedImage: UIImage?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if let uiImage = selectedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 260, height: 140)
                        .clipped()
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                } else {
                    HStack {
                        
                        Spacer()

                        VStack(spacing: 8) {
                            Image(systemName: "photo.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 34, height: 34)
                                .foregroundColor(.white)
                            
                            Text("Adicionar Imagem")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .frame(height: 140)
                        
                        Spacer()
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.10, green: 0.15, blue: 0.25),
                                Color(red: 0.07, green: 0.10, blue: 0.15)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ).opacity(0.9)
                    )
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                }
            }
        }
    }
}
