//
//  Next.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 09/02/25.
//

import SwiftUI

struct Next: View {
    var body: some View {
        ZStack {
            Color.pink.ignoresSafeArea()

            VStack {
                Button {
                    
                } label: {
                    Image(systemName: "x.circle")
                        .foregroundStyle(.black)
                        .font(.system(size: 50))
                        .frame(width: 50)
                        .padding(.leading)
                }
                
                Text("Teste")
                    .font(.system(size: 50, weight: .bold))
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    Next()
}
