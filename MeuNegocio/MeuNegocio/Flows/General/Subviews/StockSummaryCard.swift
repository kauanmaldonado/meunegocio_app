//
//  StockSummaryCard.swift
//  MeuNegocio
//

import SwiftUI

struct StockSummaryCard: View {

    @ObservedObject var vm: GeneralViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.color6B7280.opacity(0.1), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 14) {

                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.25, green: 0.55, blue: 0.95).opacity(0.12))
                            .frame(width: 38, height: 38)
                        Image(systemName: "cube.box.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color(red: 0.25, green: 0.55, blue: 0.95))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Resumo do estoque")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.color111827)
                        Text("Situação atual dos produtos")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.color6B7280)
                    }
                    Spacer()
                }

                HStack(spacing: 0) {
                    StockMetric(label: "Produtos",    value: "\(vm.allItems.count)")
                    Divider().frame(height: 32).padding(.horizontal, 12)
                    StockMetric(label: "Em dia",      value: "\(vm.goodStockCount)")
                    Divider().frame(height: 32).padding(.horizontal, 12)
                    StockMetric(label: "Valor total", value: vm.totalStockValue.toCurrency())
                }
            }
            .padding(16)
        }
    }
}

private struct StockMetric: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.color6B7280)
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.color111827)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
