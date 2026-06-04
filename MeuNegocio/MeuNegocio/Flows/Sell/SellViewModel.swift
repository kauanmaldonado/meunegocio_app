//
//  SellViewModel.swift
//  MeuNegocio
//

import Foundation

class SellViewModel: ObservableObject {

    @Published var sales: [Sale] = []

    private let salesKey = "sales"

    init() {
        loadSales()
    }

    func loadSales() {
        guard let data = UserDefaults.standard.data(forKey: salesKey),
              let decoded = try? JSONDecoder().decode([Sale].self, from: data) else {
            sales = []
            return
        }
        sales = decoded
    }

    func registerSale(items: [SaleItem], stockViewModel: StockViewModel) {
        let sale = Sale(items: items)
        sales.insert(sale, at: 0)
        saveSales()

        for saleItem in items {
            guard let index = stockViewModel.items.firstIndex(where: { $0.id == saleItem.productId }) else { continue }
            let product = stockViewModel.items[index]

            if product.isComposite {
                // Desconta os ingredientes; o composto não tem estoque próprio
                for ing in product.ingredients {
                    if let i = stockViewModel.items.firstIndex(where: { $0.code == ing.code }) {
                        stockViewModel.items[i].quantity -= ing.quantityPerUnit * saleItem.quantity
                    }
                }
            } else {
                stockViewModel.items[index].quantity -= saleItem.quantity
            }
        }
    }

    func deleteSale(_ sale: Sale) {
        sales.removeAll { $0.id == sale.id }
        saveSales()
    }

    var todayTotal: Double {
        let calendar = Calendar.current
        return sales
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.total }
    }

    var todayCount: Int {
        let calendar = Calendar.current
        return sales.filter { calendar.isDateInToday($0.date) }.count
    }

    // Agrupa vendas em períodos para o histórico
    var groupedSales: [(title: String, total: Double, sales: [Sale])] {
        guard !sales.isEmpty else { return [] }

        let calendar = Calendar.current
        let now = Date()

        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!

        var today: [Sale] = []
        var yesterday: [Sale] = []
        var thisWeek: [Sale] = []
        var thisMonth: [Sale] = []
        var older: [String: [Sale]] = [:]

        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "pt_BR")
        monthFormatter.dateFormat = "MMMM 'de' yyyy"

        for sale in sales {
            if calendar.isDateInToday(sale.date) {
                today.append(sale)
            } else if calendar.isDateInYesterday(sale.date) {
                yesterday.append(sale)
            } else if sale.date >= startOfWeek {
                thisWeek.append(sale)
            } else if sale.date >= startOfMonth {
                thisMonth.append(sale)
            } else {
                let key = monthFormatter.string(from: sale.date).capitalized
                older[key, default: []].append(sale)
            }
        }

        var result: [(title: String, total: Double, sales: [Sale])] = []

        func group(_ title: String, _ list: [Sale]) {
            guard !list.isEmpty else { return }
            result.append((title, list.reduce(0) { $0 + $1.total }, list))
        }

        group("Hoje", today)
        group("Ontem", yesterday)
        group("Esta semana", thisWeek)
        group("Este mês", thisMonth)

        // meses mais antigos em ordem cronológica decrescente
        let sortedKeys = older.keys.sorted { a, b in
            let dateA = older[a]!.first!.date
            let dateB = older[b]!.first!.date
            return dateA > dateB
        }
        for key in sortedKeys {
            group(key, older[key]!)
        }

        return result
    }

    private func saveSales() {
        if let encoded = try? JSONEncoder().encode(sales) {
            UserDefaults.standard.set(encoded, forKey: salesKey)
        }
    }
}
