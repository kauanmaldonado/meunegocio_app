//
//  TopProductsListView.swift
//  MeuNegocio
//

import SwiftUI

struct TopProductsListView: View {

    let products: [ProductSalesSummary]

    @Environment(\.dismiss) var dismiss
    @State private var sortOption: ProductSortOption = .qty

    private var sortedProducts: [ProductSalesSummary] {
        switch sortOption {
        case .qty:     return products.sorted { $0.qty > $1.qty }
        case .revenue: return products.sorted { $0.revenue > $1.revenue }
        case .profit:  return products.sorted { $0.profit > $1.profit }
        case .margin:  return products.sorted { $0.margin > $1.margin }
        }
    }

    private var totalRevenue: Double { products.reduce(0) { $0 + $1.revenue } }
    private var totalProfit: Double { products.reduce(0) { $0 + $1.profit } }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Resumo
                summaryHeader
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                // Chips de ordenação
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ProductSortOption.allCases) { option in
                            chip(option)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }

                if products.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(Array(sortedProducts.enumerated()), id: \.element.id) { index, product in
                            ProductRow(rank: index + 1, product: product, sortOption: sortOption)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.colorF3F4F6)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.colorF3F4F6)
                    .scrollIndicators(.hidden)
                }
            }
            .background(Color.colorF3F4F6)
            .navigationTitle("Produtos vendidos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.color111827)
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var summaryHeader: some View {
        HStack(spacing: 10) {
            SummaryBox(title: "Faturamento", value: totalRevenue.toCurrency(), color: Color(red: 0.25, green: 0.55, blue: 0.95))
            SummaryBox(title: "Lucro", value: totalProfit.toCurrency(), color: Color.color22C55E)
        }
    }

    private func chip(_ option: ProductSortOption) -> some View {
        let selected = sortOption == option
        return Button {
            sortOption = option
        } label: {
            HStack(spacing: 6) {
                Image(systemName: option.icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(option.rawValue)
                    .font(.system(size: 13, weight: selected ? .bold : .regular))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(selected ? Color.color111827 : Color.white)
            .foregroundStyle(selected ? Color.white : Color.color6B7280)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(selected ? Color.clear : Color.colorE5E7EB, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "shippingbox")
                .font(.system(size: 44))
                .foregroundStyle(Color.color6B7280.opacity(0.5))
            Text("Nenhuma venda no mês")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.color6B7280)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - SummaryBox

private struct SummaryBox: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(Color.color6B7280)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.color6B7280.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - ProductRow

private struct ProductRow: View {

    let rank: Int
    let product: ProductSalesSummary
    let sortOption: ProductSortOption

    var body: some View {
        HStack(spacing: 12) {
            // Posição
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Text("\(rank)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(rankColor)
            }

            // Nome + quantidade
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.color111827)
                    .lineLimit(1)
                Text("\(product.qty.formatted(.number.precision(.fractionLength(0...2)))) und. vendidas")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.color6B7280)
            }

            Spacer()

            // Valores
            VStack(alignment: .trailing, spacing: 2) {
                Text(product.revenue.toCurrency())
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.color111827)
                HStack(spacing: 4) {
                    Text("Lucro:")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.color6B7280)
                    Text(product.profit.toCurrency())
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(product.profit >= 0 ? Color.color22C55E : Color.colorEF4444)
                    Text("(\(String(format: "%.0f", product.margin))%)")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.color6B7280)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.color6B7280.opacity(0.08), radius: 3, x: 0, y: 1)
    }

    private var rankColor: Color {
        switch rank {
        case 1: return Color.colorEAB308
        case 2: return Color.color6B7280
        case 3: return Color(red: 0.72, green: 0.45, blue: 0.20)
        default: return Color(red: 0.25, green: 0.55, blue: 0.95)
        }
    }
}
