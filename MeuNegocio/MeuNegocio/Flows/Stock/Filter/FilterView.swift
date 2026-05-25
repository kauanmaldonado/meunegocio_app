//
//  FilterView.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 19/03/25.
//

import SwiftUI

struct FilterView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(Color.colorF3F4F6)

                VStack {
                    
                    Spacer().frame(height: 16)
                    
                    Text("Filtro")
                        .foregroundStyle(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.10, green: 0.15, blue: 0.25), // Azul Cobalto Suave
                                Color(red: 0.07, green: 0.10, blue: 0.15)  // Azul Noturno
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .font(.system(size: 26, weight: .bold))

                    Spacer()
                }
            }

            Button {
            } label: {
                Text("Filtrar")
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .bold))
                    .background(LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.10, green: 0.15, blue: 0.25),
                            Color(red: 0.07, green: 0.10, blue: 0.15)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(10)
            }
        }
    }
}

#Preview {
    FilterView()
}
