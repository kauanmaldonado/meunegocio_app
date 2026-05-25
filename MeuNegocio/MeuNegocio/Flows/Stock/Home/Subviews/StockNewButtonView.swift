//
//  StockNewButtonView.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 27/03/25.
//

import SwiftUI

struct StockNewButtonView: View {

    var action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: action) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.colorF3F4F6)
                    .frame(width: 50, height: 50)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.10, green: 0.15, blue: 0.25),
                            Color(red: 0.07, green: 0.10, blue: 0.15)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
        .padding(.horizontal, 20)
    }
}
