//
//  GeneralViewModel.swift
//  MeuNegocio
//

import SwiftUI

// MARK: - ChartPeriod

enum ChartPeriod: String, CaseIterable {
    case sevenDays   = "7 dias"
    case thirtyDays  = "30 dias"
    case threeMonths = "3 meses"

    var days: Int {
        switch self {
        case .sevenDays:   return 7
        case .thirtyDays:  return 30
        case .threeMonths: return 90
        }
    }
}

// MARK: - ProductSalesSummary

struct ProductSalesSummary: Identifiable {
    let id = UUID()
    let name: String
    let qty: Double
    let revenue: Double
    let profit: Double

    var margin: Double {
        revenue > 0 ? (profit / revenue) * 100 : 0
    }
}

// MARK: - ProductSortOption

enum ProductSortOption: String, CaseIterable, Identifiable {
    case qty      = "Mais vendidos"
    case revenue  = "Maior faturamento"
    case profit   = "Maior lucro"
    case margin   = "Maior margem"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .qty:     return "shippingbox.fill"
        case .revenue: return "dollarsign.circle.fill"
        case .profit:  return "chart.line.uptrend.xyaxis"
        case .margin:  return "percent"
        }
    }
}

// MARK: - GeneralViewModel

class GeneralViewModel: ObservableObject {

    // Vendas de hoje
    @Published var todayTotal: Double = 0
    @Published var todayCount: Int = 0
    @Published var todayTicketAvg: Double = 0

    // Lucro estimado do dia
    @Published var todayProfit: Double = 0
    @Published var todayAvgMargin: Double = 0

    // Estoque
    @Published var allItems: [StockViewCellData] = []
    @Published var lowStock: [StockViewCellData] = []
    @Published var totalStockValue: Double = 0
    @Published var goodStockCount: Int = 0

    // Top produtos do mês
    @Published var topProducts: [ProductSalesSummary] = []
    @Published var allProductsSummary: [ProductSalesSummary] = []

    // Gráfico
    @Published var chartPeriod: ChartPeriod = .sevenDays {
        didSet { buildChartData() }
    }
    @Published var chartData: [(date: Date, total: Double)] = []

    // MARK: - Public

    func load() {
        loadStock()
        loadSales()
        buildChartData()
    }

    func buildChartData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -(chartPeriod.days - 1), to: today) else { return }

        let allSales = fetchSales()

        // Agrupa total por dia
        var byDay: [Date: Double] = [:]
        for sale in allSales {
            let day = calendar.startOfDay(for: sale.date)
            guard day >= startDate else { continue }
            byDay[day, default: 0] += sale.total
        }

        // Gera um ponto por dia no período (zero se não houver vendas)
        var points: [(date: Date, total: Double)] = []
        var cursor = startDate
        while cursor <= today {
            points.append((cursor, byDay[cursor] ?? 0))
            cursor = calendar.date(byAdding: .day, value: 1, to: cursor) ?? cursor
        }
        chartData = points
    }

    // MARK: - Private

    private func loadStock() {
        guard let data = UserDefaults.standard.data(forKey: "items"),
              let items = try? JSONDecoder().decode([StockViewCellData].self, from: data) else {
            allItems = []; lowStock = []; totalStockValue = 0; goodStockCount = 0
            return
        }
        allItems       = items
        lowStock       = items.filter { $0.stockLevel != .goodStock }
        totalStockValue = items.reduce(0) { $0 + $1.unitPrice * $1.quantity }
        goodStockCount  = items.filter { $0.stockLevel == .goodStock }.count
    }

    private func loadSales() {
        let calendar = Calendar.current
        let allSales = fetchSales()

        // Hoje
        let today = allSales.filter { calendar.isDateInToday($0.date) }
        todayTotal    = today.reduce(0) { $0 + $1.total }
        todayCount    = today.count
        todayTicketAvg = todayCount > 0 ? todayTotal / Double(todayCount) : 0

        // Lucro estimado — join por productName
        var totalProfit: Double = 0
        var weightedMargin: Double = 0
        var totalRevForMargin: Double = 0

        for sale in today {
            for item in sale.items {
                let cost = allItems.first(where: { $0.productName == item.productName })?.unitCost ?? 0
                let revenue = item.unitPrice * item.quantity
                let profit  = (item.unitPrice - cost) * item.quantity
                totalProfit += profit
                weightedMargin += profit
                totalRevForMargin += revenue
            }
        }
        todayProfit    = totalProfit
        todayAvgMargin = totalRevForMargin > 0 ? (weightedMargin / totalRevForMargin) * 100 : 0

        // Produtos do mês (com lucro)
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let monthSales   = allSales.filter { $0.date >= startOfMonth }

        var productMap: [String: (qty: Double, revenue: Double, profit: Double)] = [:]
        for sale in monthSales {
            for item in sale.items {
                let cost = allItems.first(where: { $0.productName == item.productName })?.unitCost ?? 0
                let revenue = item.total
                let profit  = (item.unitPrice - cost) * item.quantity
                let prev = productMap[item.productName] ?? (0, 0, 0)
                productMap[item.productName] = (prev.qty + item.quantity,
                                                prev.revenue + revenue,
                                                prev.profit + profit)
            }
        }

        let summaries = productMap.map {
            ProductSalesSummary(name: $0.key, qty: $0.value.qty, revenue: $0.value.revenue, profit: $0.value.profit)
        }

        allProductsSummary = summaries.sorted { $0.qty > $1.qty }
        topProducts = Array(allProductsSummary.prefix(3))
    }

    private func fetchSales() -> [Sale] {
        guard let data = UserDefaults.standard.data(forKey: "sales"),
              let sales = try? JSONDecoder().decode([Sale].self, from: data) else { return [] }
        return sales
    }
}
