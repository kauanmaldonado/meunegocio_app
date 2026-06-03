//
//  GeneralView.swift
//  MeuNegocio
//

import SwiftUI

// MARK: - GeneralView

struct GeneralView: View {

    @StateObject private var vm = GeneralViewModel()

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.96, alpha: 1.0)
        let titleColor = UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1.0)
        appearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                SalesChartCard(vm: vm)
                TodaySalesCard(vm: vm)
                ProfitCard(vm: vm)
                StockSummaryCard(vm: vm)

                if !vm.lowStock.isEmpty {
                    LowStockCard(items: vm.lowStock) { }
                }

                if !vm.topProducts.isEmpty {
                    TopProductsCard(products: vm.topProducts)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 130)
        }
        .background(Color.colorF3F4F6)
        .navigationTitle("Geral")
        .toolbarTitleDisplayMode(.large)
        .onAppear { vm.load() }
    }
}

// MARK: - LowStockCard

struct LowStockCard: View {

    let items: [StockViewCellData]
    let onTap: () -> Void

    private var outOfStockCount: Int {
        items.filter { $0.stockLevel == .exhausted }.count
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.color111827)
                    .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 8)

                VStack(alignment: .leading, spacing: 14) {

                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.10))
                                .frame(width: 38, height: 38)
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Estoque baixo")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("Itens abaixo do mínimo configurado")
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.68))
                        }

                        Spacer()

                        Text("\(items.count)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 10) {
                        SummaryPill(title: "Atenção", value: "\(items.count)")
                        SummaryPill(title: "Zerados", value: "\(outOfStockCount)")
                    }

                    VStack(spacing: 10) {
                        ForEach(items.prefix(2)) { item in
                            LowStockRow(item: item)
                        }
                    }

                    HStack {
                        Text("Ver todos")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.92))
                        Spacer().frame(width: 16)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.75))
                        Spacer()
                    }
                    .padding(.top, 2)
                }
                .padding(16)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - LowStockCard subcomponents

private struct SummaryPill: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.70))
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.10))
        .clipShape(Capsule())
    }
}

private struct LowStockRow: View {

    let item: StockViewCellData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Circle()
                    .fill(item.stockLevel == .exhausted ? Color.white.opacity(0.95) : Color.white.opacity(0.35))
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.productName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("\(item.quantity.formatted(.number.precision(.fractionLength(0...2)))) em estoque • mínimo \(item.minimumQuantity.formatted(.number.precision(.fractionLength(0...2))))")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.65))
                }

                Spacer()

                Text(item.stockLevel == .exhausted ? "SEM" : "BAIXO")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(item.stockLevel == .exhausted ? 0.16 : 0.10))
                    .clipShape(Capsule())
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(item.stockLevel == .exhausted ? 0.90 : 0.55))
                        .frame(width: geo.size.width * item.ratio, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
