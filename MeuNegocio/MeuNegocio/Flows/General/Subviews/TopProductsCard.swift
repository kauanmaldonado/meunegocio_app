//
//  TopProductsCard.swift
//  MeuNegocio
//

import SwiftUI

struct TopProductsCard: View {

    let products: [(name: String, qty: Double, revenue: Double)]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.color6B7280.opacity(0.1), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 14) {

                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.colorEAB308.opacity(0.15))
                            .frame(width: 38, height: 38)
                        Image(systemName: "star.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.colorEAB308)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Top produtos")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.color111827)
                        Text("Mais vendidos no mês atual")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.color6B7280)
                    }
                    Spacer()
                }

                VStack(spacing: 10) {
                    ForEach(Array(products.enumerated()), id: \.offset) { index, product in
                        HStack(spacing: 12) {
                            // Posição
                            ZStack {
                                Circle()
                                    .fill(rankColor(index).opacity(0.15))
                                    .frame(width: 28, height: 28)
                                Text("\(index + 1)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(rankColor(index))
                            }

                            Text(product.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.color111827)
                                .lineLimit(1)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 1) {
                                Text(product.revenue.toCurrency())
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.color111827)
                                Text("\(product.qty.formatted(.number.precision(.fractionLength(0...2)))) und.")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.color6B7280)
                            }
                        }

                        if index < products.count - 1 {
                            Divider().background(Color.colorE5E7EB)
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    private func rankColor(_ index: Int) -> Color {
        switch index {
        case 0: return Color.colorEAB308
        case 1: return Color.color6B7280
        default: return Color(red: 0.72, green: 0.45, blue: 0.20)
        }
    }
}
