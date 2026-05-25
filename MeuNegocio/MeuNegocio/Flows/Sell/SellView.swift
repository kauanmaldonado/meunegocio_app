//
//  SellView.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 09/02/25.
//

import SwiftUI

struct SellView: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            ZStack(alignment: .leading) {
                Color(red: 0.10, green: 0.15, blue: 0.25)

                Text("Suas Vendas")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 64)
                    .padding(.bottom, 32)
                
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, 20)
            .padding(.top, 40)
            .background(Color(red: 0.10, green: 0.15, blue: 0.25))
            .edgesIgnoringSafeArea(.all)

            List {
                
                    Text("Conteúdo abaixo com fundo branco")
                        .font(.system(size: 20))
                        .listRowSeparator(.hidden)
            }
            .padding(.top, -44)
            .listStyle(.plain)
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    SellView()
}
