//
//  FilterViewModel.swift
//  MeuNegocio
//

import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case nameAZ       = "Nome A→Z"
    case nameZA       = "Nome Z→A"
    case priceAsc     = "Preço ↑"
    case priceDesc    = "Preço ↓"
    case qtyAsc       = "Quantidade ↑"
    case qtyDesc      = "Quantidade ↓"

    var id: String { rawValue }
}

class FilterViewModel: ObservableObject {

    @Published var selectedLevels: Set<StockViewCellData.StockLevel> = []
    @Published var sortOption: SortOption = .nameAZ
    @Published var minQty: Double = 0
    @Published var maxQty: Double = 9999

    var isActive: Bool {
        !selectedLevels.isEmpty || sortOption != .nameAZ || minQty > 0 || maxQty < 9999
    }

    func apply(to items: [StockViewCellData]) -> [StockViewCellData] {
        var result = items

        if !selectedLevels.isEmpty {
            result = result.filter { selectedLevels.contains($0.stockLevel) }
        }

        result = result.filter { $0.quantity >= minQty && $0.quantity <= maxQty }

        switch sortOption {
        case .nameAZ:    result.sort { $0.productName.lowercased() < $1.productName.lowercased() }
        case .nameZA:    result.sort { $0.productName.lowercased() > $1.productName.lowercased() }
        case .priceAsc:  result.sort { $0.unitPrice < $1.unitPrice }
        case .priceDesc: result.sort { $0.unitPrice > $1.unitPrice }
        case .qtyAsc:    result.sort { $0.quantity < $1.quantity }
        case .qtyDesc:   result.sort { $0.quantity > $1.quantity }
        }

        return result
    }

    func reset() {
        selectedLevels = []
        sortOption = .nameAZ
        minQty = 0
        maxQty = 9999
    }
}
