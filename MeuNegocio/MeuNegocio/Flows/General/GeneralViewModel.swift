//
//  GeneralViewModel.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 27/03/25.
//

import SwiftUI

class GeneralViewModel: ObservableObject {
    
    @Published var selectedDate: Date = Date()

    @Published var lowStock: [StockViewCellData] = [] {
        didSet {

        }
    }

    // MARK: Initializers
    init() {
        guard let data = UserDefaults.standard.data(forKey: "items") else { return }

        if let getItems = try? JSONDecoder().decode([StockViewCellData].self, from: data) {
            self.lowStock = getItems.filter { $0.stockLevel != .goodStock }
        }
    }

    func load(date: Date) {
        // aqui você buscaria no seu storage (CoreData/Realm/Firestore/etc)
        // e atualizaria lowStock, soldItems, summary e série do gráfico.
    }
}
