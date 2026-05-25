//
//  DetailViewModel.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 22/08/25.
//

import SwiftUI

class DetailViewModel: ObservableObject {

    @Published var item: StockViewCellData = .init() {
        didSet {

        }
    }

    // MARK: Initializers
    init(code: String) {
        guard let data = UserDefaults.standard.data(forKey: "items") else {
            print("## data")
            return
        }

        if let getItems = try? JSONDecoder().decode([StockViewCellData].self, from: data) {
            guard let getItem = getItems.first(where: { $0.code == code }) else {
                return
            }
            self.item = getItem
        }
    }
    
    func persistChanges() {
        guard let data = UserDefaults.standard.data(forKey: "items"),
              var items = try? JSONDecoder().decode([StockViewCellData].self, from: data) else { return }

        if let idx = items.firstIndex(where: { $0.code == item.code }) {
            items[idx] = item
        } else {
            items.append(item)
        }

        if let newData = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(newData, forKey: "items")
        }
    }
}
