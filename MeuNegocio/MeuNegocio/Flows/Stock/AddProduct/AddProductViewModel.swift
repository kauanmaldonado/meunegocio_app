//
//  AddProductViewModel.swift
//  MeuNegocio
//

import SwiftUI

enum AddProductMode { case add, edit }

class AddProductViewModel: ObservableObject {

    let mode: AddProductMode

    @Published var item = StockViewCellData()
    @Published var isShowingSourcePicker = false
    @Published var isShowingImagePicker: Bool = false
    @Published var isShowingQRScanner: Bool = false

    @Published var unitCostText: String = ""
    @Published var unitPriceText: String = ""
    @Published var quantityText: String = ""
    @Published var minimumQuantityText: String = ""
    @Published var unit: StockViewCellData.Unit = .un

    // MARK: - Inicializadores

    init() {
        self.mode = .add
    }

    init(editing product: StockViewCellData) {
        self.mode = .edit
        self.item = product
        self.unit = product.unit
        self.unitCostText = Self.formatToCurrencyString(product.unitCost)
        self.unitPriceText = Self.formatToCurrencyString(product.unitPrice)
        self.quantityText = product.unit == .un
            ? "\(Int(product.quantity))"
            : String(format: "%.1f", product.quantity)
        self.minimumQuantityText = product.unit == .un
            ? "\(Int(product.minimumQuantity))"
            : String(format: "%.1f", product.minimumQuantity)
    }

    // MARK: - Persistência

    func saveItems() {
        var currentItems: [StockViewCellData] = []
        if let data = UserDefaults.standard.data(forKey: "items"),
           let decoded = try? JSONDecoder().decode([StockViewCellData].self, from: data) {
            currentItems = decoded
        }
        item.unitCost = tranformToDouble(to: unitCostText)
        item.unitPrice = tranformToDouble(to: unitPriceText)
        item.quantity = Double(quantityText) ?? 0
        item.minimumQuantity = Double(minimumQuantityText) ?? 0
        item.unit = unit
        currentItems.append(item)
        if let encoded = try? JSONEncoder().encode(currentItems) {
            UserDefaults.standard.set(encoded, forKey: "items")
        }
    }

    func updateItem() {
        guard let data = UserDefaults.standard.data(forKey: "items"),
              var items = try? JSONDecoder().decode([StockViewCellData].self, from: data) else { return }
        item.unitCost = tranformToDouble(to: unitCostText)
        item.unitPrice = tranformToDouble(to: unitPriceText)
        item.quantity = Double(quantityText) ?? 0
        item.minimumQuantity = Double(minimumQuantityText) ?? 0
        item.unit = unit
        if let idx = items.firstIndex(where: { $0.code == item.code }) {
            items[idx] = item
        }
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "items")
        }
    }

    func saveImageToDocuments(_ image: UIImage, named name: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(name).jpg")
        do {
            try data.write(to: url)
            item.productURLImage = url.path
        } catch {
            print("Erro ao salvar imagem: \(error)")
        }
    }

    func tranformToDouble(to value: String) -> Double {
        let digits = value.filter { "0123456789".contains($0) }
        return (Double(digits) ?? 0) / 100
    }

    func applyCurrencyMask(to value: String) -> String {
        let digits = value.filter { "0123456789".contains($0) }
        let doubleValue = (Double(digits) ?? 0) / 100
        item.unitCost = doubleValue
        return Self.formatToCurrencyString(doubleValue)
    }

    func applyPriceMask(to value: String) -> String {
        let digits = value.filter { "0123456789".contains($0) }
        let doubleValue = (Double(digits) ?? 0) / 100
        item.unitPrice = doubleValue
        return Self.formatToCurrencyString(doubleValue)
    }

    static func formatToCurrencyString(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }
}
