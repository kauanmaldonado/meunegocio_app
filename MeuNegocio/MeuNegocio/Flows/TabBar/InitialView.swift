//
//  InitialView.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 09/02/25.
//

import SwiftUI

struct InitialView: View {

    @State private var selection: Int = 1

    var body: some View {
        NavigationStack {
            ZStack {
                Color(Color.colorF3F4F6).ignoresSafeArea()

                VStack(spacing: 0) {
                    
                    VStack {
                        // Conteúdo da tela
                        ZStack {
                            switch selection {
                            case 0:
                                SellView()
                            case 1:
                                GeneralView()
                            case 2:
                                StockView()
                            case 3:
                                ConfigView()
                            default:
                                GeneralView()
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, -70)

                    VStack {
                        RoundedRectangle(cornerRadius: 35, style: .continuous)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.10, green: 0.15, blue: 0.25), // Azul Cobalto Suave
                                    Color(red: 0.07, green: 0.10, blue: 0.15)  // Azul Noturno
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            .frame(height: 70)
                            .overlay(
                                HStack {
                                    Spacer()
                                    TabBarButton(imageName: "rectangle.portrait.on.rectangle.portrait", label: "Vendas", isSelected: selection == 0) {
                                        selection = 0
                                    }
                                    Spacer()
                                    TabBarButton(imageName: "house.fill", label: "Geral", isSelected: selection == 1) {
                                        selection = 1
                                    }
                                    Spacer()
                                    TabBarButton(imageName: "cube.box.fill", label: "Estoque", isSelected: selection == 2) {
                                        selection = 2
                                    }
                                    Spacer()
                                }
                            )
                    }
                    .padding(.bottom, 2)
                    .padding(.horizontal, 10)
                }
            }
        }
    }
}

#Preview {
    InitialView()
}
