//
//  Sale.swift
//  MeuNegocio
//

import Foundation

struct SaleItem: Identifiable, Codable {

    let id: UUID
    let productId: UUID
    let productName: String
    let quantity: Double
    let unitPrice: Double

    var total: Double { quantity * unitPrice }

    init(productId: UUID, productName: String, quantity: Double, unitPrice: Double) {
        self.id = UUID()
        self.productId = productId
        self.productName = productName
        self.quantity = quantity
        self.unitPrice = unitPrice
    }
}

struct Sale: Identifiable, Codable {

    let id: UUID
    let date: Date
    let items: [SaleItem]

    var total: Double { items.reduce(0) { $0 + $1.total } }

    init(items: [SaleItem]) {
        self.id = UUID()
        self.date = Date()
        self.items = items
    }
}
