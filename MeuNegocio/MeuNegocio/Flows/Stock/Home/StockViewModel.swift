//
//  StockViewModel.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 27/03/25.
//

import SwiftUI

class StockViewModel: ObservableObject {

    @Published var searchIsActive = false
    @Published var searchResults: [StockViewCellData] = []
    @Published var searchQuery: String = ""

    @Published var items: [StockViewCellData] = [] {
        didSet {
            saveItems()
        }
    }

    // MARK: Initializers
    init() {
        guard let data = UserDefaults.standard.data(forKey: "items") else { return }

        if let getItems = try? JSONDecoder().decode([StockViewCellData].self, from: data) {
            self.items = getItems
        }
    }

    func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: "items") else {
            items = []
            return
        }

        if let getItems = try? JSONDecoder().decode([StockViewCellData].self, from: data) {
            self.items = getItems
        }
    }

    func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "items")
        }
    }

    func fetchSearchResults() {
        searchResults = items.filter { item in
            item.productName
                .lowercased()
                .contains(searchQuery)
        }
    }
    
    func fetchItems() -> [StockViewCellData] {
        if searchIsActive && searchResults.isEmpty && searchQuery.isEmpty {
            return items
        } else if searchIsActive && !searchResults.isEmpty && !searchQuery.isEmpty {
            return searchResults
        } else if searchIsActive && searchResults.isEmpty && !searchQuery.isEmpty {
            return []
        } else if searchIsActive && !searchResults.isEmpty && searchQuery.isEmpty {
            return items
        }

        return items
    }
}
