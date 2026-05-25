//
//  ConfigView.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 09/02/25.
//

import SwiftUI

struct ConfigView: View {

    @State private var goNextView: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Button {
                    goNextView.toggle()
                } label: {
                    Text("Teste")
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .foregroundStyle(.black)
                        .font(.system(size: 18, weight: .bold))
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
//                ScrollView {
//                    Group {
//                        VStack {
//                            Text("Configuracões do seu Perfil.")
//                        }
//                    }
//                    .foregroundStyle(.white)
//                }
            }
        }
        .fullScreenCover(isPresented: $goNextView, content: {
            Next()
        })
//        .navigationDestination(isPresented: $goNextView) {
//            Next()
//        }
    }
}

#Preview {
    ConfigView()
}
