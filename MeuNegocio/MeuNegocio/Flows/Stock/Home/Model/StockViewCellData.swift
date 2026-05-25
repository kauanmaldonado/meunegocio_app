//
//  StockViewCellData.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 14/02/25.
//

import Foundation
import SwiftUI

struct StockViewCellData: Identifiable, Codable {

    let id = UUID()
    var productName: String
    var productURLImage: String
    var code: String
    var unitPrice: Double
    var unitCost: Double
    var quantity: Double
    var minimumQuantity: Double
    var unit: Unit = .un

//    var isOutOfStock: Bool {
//        quantity == 0
//    }

    var profit: Double {
        unitPrice - unitCost
    }
    
    var profitPercentage: Double {
        (profit / unitCost) * 100
    }

    var totalValue: Double {
        unitPrice * Double(quantity)
    }

    var stockLevel: StockLevel {
        if quantity == 0 {
            return .exhausted
        } else if quantity < minimumQuantity {
            return .lowStock
        }

        return .goodStock
    }

    var ratio: Double {
        guard minimumQuantity > 0 else { return 0 }
        return min(max(Double(quantity) / Double(minimumQuantity), 0), 1)
    }

    enum Unit: String, CaseIterable, Codable, Identifiable {
        case un, kg, ml
        var id: String { rawValue }
        var title: String {
            switch self {
            case .un: return "unitário"
            case .kg: return "kg"
            case .ml: return "ml"
            }
        }
    }

    enum StockLevel {

        case exhausted
        case goodStock
        case lowStock

        var title: String {
            switch self {
            case .exhausted:
                "Esgotado"
            case .goodStock:
                "Em estoque"
            case .lowStock:
                "Baixo estoque"
            }
        }

        var color: Color {
            switch self {
            case .exhausted: return .colorEF4444
            case .goodStock: return .color22C55E
            case .lowStock: return .colorEAB308
            }
        }
    }

    init() {
        self.productName = ""
        self.productURLImage = ""
        self.code = ""
        self.quantity = 0
        self.minimumQuantity = 0
        self.unitPrice = 0
        self.unitCost = 0
    }
}
