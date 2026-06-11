//
//  DetailViewModel.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 22/08/25.
//

import SwiftUI

class DetailViewModel: ObservableObject {

    @Published var item: StockViewCellData = .init()
    @Published var allItems: [StockViewCellData] = []

    // Disponibilidade (composto = derivada dos ingredientes; simples = quantidade)
    var available: Double { item.availableUnits(in: allItems) }

    // Custo resolvido (composto = soma dos ingredientes; simples = custo médio)
    var resolvedCost: Double { item.resolvedUnitCost(in: allItems) }

    var profit: Double { item.unitPrice - resolvedCost }
    var margin: Double { resolvedCost > 0 ? (profit / resolvedCost) * 100 : 0 }

    // Status considerando composto
    var isOutOfStock: Bool {
        item.isComposite ? available <= 0 : item.quantity <= 0
    }

    // MARK: Initializers
    init(productId: UUID) {
        guard let data = UserDefaults.standard.data(forKey: "items"),
              let getItems = try? JSONDecoder().decode([StockViewCellData].self, from: data) else { return }
        self.allItems = getItems
        if let getItem = getItems.first(where: { $0.id == productId }) {
            self.item = getItem
        }
    }
    
    func deleteProduct() {
        guard let data = UserDefaults.standard.data(forKey: "items"),
              var items = try? JSONDecoder().decode([StockViewCellData].self, from: data) else { return }
        items.removeAll { $0.id == item.id }
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "items")
        }
    }

    func persistChanges() {
        guard let data = UserDefaults.standard.data(forKey: "items"),
              var items = try? JSONDecoder().decode([StockViewCellData].self, from: data) else { return }

        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = item
        } else {
            items.append(item)
        }

        if let newData = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(newData, forKey: "items")
        }
    }
}
