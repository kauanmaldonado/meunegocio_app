//
//  SellView.swift
//  MeuNegocio
//

import SwiftUI

struct SellView: View {

    @StateObject private var sellViewModel = SellViewModel()
    @StateObject private var stockViewModel = StockViewModel()
    @State private var showNewSale = false

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        if let image = gradientImage() { appearance.backgroundImage = image }
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                // Resumo do dia
                Section {
                    DailySummaryCard(total: sellViewModel.todayTotal, count: sellViewModel.todayCount)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.colorF3F4F6)
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 4, trailing: 16))

                // Histórico
                if sellViewModel.sales.isEmpty {
                    Section {
                        emptySalesView
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.colorF3F4F6)
                } else {
                    Section {
                        ForEach(sellViewModel.sales) { sale in
                            SaleCard(sale: sale)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.colorF3F4F6)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                        .onDelete { offsets in
                            offsets.forEach { sellViewModel.deleteSale(sellViewModel.sales[$0]) }
                        }
                    } header: {
                        Text("Histórico")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.color6B7280)
                            .textCase(nil)
                    }
                    .listRowBackground(Color.colorF3F4F6)
                }

                Spacer()
                    .frame(height: 80)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.colorF3F4F6)
            }
            .listStyle(.plain)
            .background(Color.colorF3F4F6)
            .scrollIndicators(.hidden)

            newSaleButton
                .padding(.bottom, 70)
        }
        .navigationTitle("Vendas")
        .toolbarTitleDisplayMode(.large)
        .onAppear {
            sellViewModel.loadSales()
            stockViewModel.loadItems()
        }
        .sheet(isPresented: $showNewSale, onDismiss: {
            sellViewModel.loadSales()
            stockViewModel.loadItems()
        }) {
            NewSaleView(stockViewModel: stockViewModel, sellViewModel: sellViewModel)
                .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Subviews

    private var emptySalesView: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 40)
            Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                .font(.system(size: 44))
                .foregroundStyle(Color.color6B7280.opacity(0.5))
            Text("Nenhuma venda registrada")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.color6B7280)
            Text("Toque em Nova Venda para começar")
                .font(.system(size: 13))
                .foregroundStyle(Color.color6B7280.opacity(0.7))
            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.colorF3F4F6)
    }

    private var newSaleButton: some View {
        Button {
            showNewSale = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                Text("Nova Venda")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.10, green: 0.15, blue: 0.25),
                        Color(red: 0.07, green: 0.10, blue: 0.15)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Gradient

    private static func gradientImage() -> UIImage? {
        let size = CGSize(width: UIScreen.main.bounds.width, height: 120)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let colors = [
                UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1.0).cgColor,
                UIColor(red: 0.07, green: 0.10, blue: 0.15, alpha: 1.0).cgColor
            ]
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: [0, 1]
            )!
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: size.width / 2, y: 0),
                end: CGPoint(x: size.width / 2, y: size.height),
                options: []
            )
        }
    }

    private func gradientImage() -> UIImage? { Self.gradientImage() }
}

// MARK: - DailySummaryCard

private struct DailySummaryCard: View {

    let total: Double
    let count: Int

    var body: some View {
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
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Vendas de hoje")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("Resumo do dia atual")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.68))
                    }

                    Spacer()
                }

                HStack(spacing: 10) {
                    SalesPill(title: "Total", value: total.toCurrency())
                    SalesPill(title: "Vendas", value: "\(count)")
                }
            }
            .padding(16)
        }
    }
}

private struct SalesPill: View {
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

// MARK: - SaleCard

private struct SaleCard: View {

    let sale: Sale

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd/MM/yyyy 'às' HH:mm"
        return formatter.string(from: sale.date)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.color6B7280.opacity(0.1), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 10) {

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dateText)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.color6B7280)
                        Text(sale.total.toCurrency())
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.color111827)
                    }

                    Spacer()

                    Text("\(sale.items.count) \(sale.items.count == 1 ? "item" : "itens")")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.color111827)
                        .clipShape(Capsule())
                }

                Divider()
                    .background(Color.colorE5E7EB)

                VStack(spacing: 4) {
                    ForEach(sale.items) { item in
                        HStack {
                            Text(item.productName)
                                .font(.system(size: 13))
                                .foregroundStyle(Color.color6B7280)
                                .lineLimit(1)
                            Spacer()
                            Text("x\(item.quantity.formatted(.number.precision(.fractionLength(0...2))))")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.color6B7280)
                            Text(item.total.toCurrency())
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.color111827)
                                .frame(minWidth: 70, alignment: .trailing)
                        }
                    }
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    SellView()
}
