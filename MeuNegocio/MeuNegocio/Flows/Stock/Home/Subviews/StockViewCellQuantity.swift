//
//  StockViewCellQuantity.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 27/03/25.
//

import SwiftUI

struct StockViewCellQuantity: View {
    
    let quantity: Double
    let stockLevel: StockViewCellData.StockLevel
    
    var body: some View {
        
        HStack(alignment: .center) {

            Circle()
                .frame(width: 10, height: 10)
                .foregroundStyle(stockLevel.color)

            Text("\(quantity) unidades")
                .font(.custom("Inter", fixedSize: 16))
                .fontWeight(.semibold)
                .foregroundStyle(Color.color4B5563)

            Spacer()
        }
    }
}
