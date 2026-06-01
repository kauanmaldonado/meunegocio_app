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
            if let index = stockViewModel.items.firstIndex(where: { $0.id == saleItem.productId }) {
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

    private func saveSales() {
        if let encoded = try? JSONEncoder().encode(sales) {
            UserDefaults.standard.set(encoded, forKey: salesKey)
        }
    }
}
