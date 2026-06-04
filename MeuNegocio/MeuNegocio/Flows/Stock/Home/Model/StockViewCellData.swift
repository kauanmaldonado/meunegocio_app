//
//  StockViewCellData.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 14/02/25.
//

import Foundation
import SwiftUI

struct RecipeIngredient: Codable, Identifiable, Hashable {
    var id = UUID()
    var code: String           // referência ESTÁVEL ao produto ingrediente
    var name: String           // cache para exibição
    var quantityPerUnit: Double // qto consome por 1 unidade do composto (unidade do ingrediente)
}

struct Restock: Codable, Identifiable, Hashable {
    var id = UUID()
    var date: Date
    var quantity: Double      // quantidade adicionada
    var unitCostPaid: Double  // custo unitário pago nesta reposição
}

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
    var isSellable: Bool = true
    var ingredients: [RecipeIngredient] = []
    var restocks: [Restock] = []

    var isComposite: Bool { !ingredients.isEmpty }

    // Custo unitário da última reposição (referência p/ comparação). Se não houver, usa o custo atual.
    var lastRestockCost: Double? {
        restocks.last?.unitCostPaid
    }

    // Custo do produto. Para composto, soma o custo dos ingredientes (custo unit. × qtd usada).
    func resolvedUnitCost(in items: [StockViewCellData]) -> Double {
        guard isComposite else { return unitCost }
        return ingredients.reduce(0) { sum, ing in
            let ingCost = items.first(where: { $0.code == ing.code })?.unitCost ?? 0
            return sum + ingCost * ing.quantityPerUnit
        }
    }

    // Aplica uma reposição usando CUSTO MÉDIO PONDERADO.
    mutating func applyRestock(quantity: Double, unitCostPaid: Double) {
        let newQty = self.quantity + quantity
        let newCost = newQty > 0
            ? (self.quantity * self.unitCost + quantity * unitCostPaid) / newQty
            : unitCostPaid
        self.quantity = newQty
        self.unitCost = newCost
        self.restocks.append(Restock(date: Date(), quantity: quantity, unitCostPaid: unitCostPaid))
    }

    // Quantas unidades do composto dá para montar com o estoque dos ingredientes.
    // Para produto simples retorna a própria quantidade.
    func availableUnits(in items: [StockViewCellData]) -> Double {
        guard isComposite else { return quantity }
        var maxBuildable = Double.greatestFiniteMagnitude
        for ing in ingredients {
            guard ing.quantityPerUnit > 0,
                  let stock = items.first(where: { $0.code == ing.code })?.quantity else { return 0 }
            maxBuildable = min(maxBuildable, floor(stock / ing.quantityPerUnit))
        }
        return maxBuildable == .greatestFiniteMagnitude ? 0 : max(0, maxBuildable)
    }

    private enum CodingKeys: String, CodingKey {
        case id, productName, productURLImage, code, unitPrice, unitCost
        case quantity, minimumQuantity, unit, isSellable, ingredients, restocks
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        productName     = try c.decode(String.self, forKey: .productName)
        productURLImage = try c.decode(String.self, forKey: .productURLImage)
        code            = try c.decode(String.self, forKey: .code)
        unitPrice       = try c.decode(Double.self, forKey: .unitPrice)
        unitCost        = try c.decode(Double.self, forKey: .unitCost)
        quantity        = try c.decode(Double.self, forKey: .quantity)
        minimumQuantity = try c.decode(Double.self, forKey: .minimumQuantity)
        unit            = try c.decodeIfPresent(Unit.self, forKey: .unit) ?? .un
        isSellable      = try c.decodeIfPresent(Bool.self, forKey: .isSellable) ?? true
        ingredients     = try c.decodeIfPresent([RecipeIngredient].self, forKey: .ingredients) ?? []
        restocks        = try c.decodeIfPresent([Restock].self, forKey: .restocks) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(productName, forKey: .productName)
        try c.encode(productURLImage, forKey: .productURLImage)
        try c.encode(code, forKey: .code)
        try c.encode(unitPrice, forKey: .unitPrice)
        try c.encode(unitCost, forKey: .unitCost)
        try c.encode(quantity, forKey: .quantity)
        try c.encode(minimumQuantity, forKey: .minimumQuantity)
        try c.encode(unit, forKey: .unit)
        try c.encode(isSellable, forKey: .isSellable)
        try c.encode(ingredients, forKey: .ingredients)
        try c.encode(restocks, forKey: .restocks)
    }

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
