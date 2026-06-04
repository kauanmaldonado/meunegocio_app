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
    @Published var isSellable: Bool = true
    @Published var ingredients: [RecipeIngredient] = []

    // Produtos já cadastrados, para escolher como ingredientes
    @Published var existingProducts: [StockViewCellData] = []

    var isComposite: Bool { !ingredients.isEmpty }

    // MARK: - Inicializadores

    init() {
        self.mode = .add
        loadExistingProducts()
    }

    init(editing product: StockViewCellData) {
        self.mode = .edit
        self.item = product
        self.unit = product.unit
        self.isSellable = product.isSellable
        self.ingredients = product.ingredients
        self.unitCostText = Self.formatToCurrencyString(product.unitCost)
        self.unitPriceText = Self.formatToCurrencyString(product.unitPrice)
        self.quantityText = product.unit == .un
            ? "\(Int(product.quantity))"
            : String(format: "%.1f", product.quantity)
        self.minimumQuantityText = product.unit == .un
            ? "\(Int(product.minimumQuantity))"
            : String(format: "%.1f", product.minimumQuantity)
        loadExistingProducts(excludingCode: product.code)
    }

    private func loadExistingProducts(excludingCode: String? = nil) {
        guard let data = UserDefaults.standard.data(forKey: "items"),
              let decoded = try? JSONDecoder().decode([StockViewCellData].self, from: data) else { return }
        existingProducts = decoded.filter { $0.code != excludingCode }
    }

    func addIngredient(_ product: StockViewCellData, quantityPerUnit: Double) {
        // evita duplicar o mesmo ingrediente
        ingredients.removeAll { $0.code == product.code }
        ingredients.append(RecipeIngredient(code: product.code,
                                            name: product.productName,
                                            quantityPerUnit: quantityPerUnit))
    }

    func removeIngredient(_ ingredient: RecipeIngredient) {
        ingredients.removeAll { $0.id == ingredient.id }
    }

    // MARK: - Persistência

    func saveItems() {
        var currentItems: [StockViewCellData] = []
        if let data = UserDefaults.standard.data(forKey: "items"),
           let decoded = try? JSONDecoder().decode([StockViewCellData].self, from: data) {
            currentItems = decoded
        }
        applyFields()
        currentItems.append(item)
        if let encoded = try? JSONEncoder().encode(currentItems) {
            UserDefaults.standard.set(encoded, forKey: "items")
        }
    }

    private func applyFields() {
        item.unitCost = tranformToDouble(to: unitCostText)
        item.unitPrice = tranformToDouble(to: unitPriceText)
        item.unit = unit
        item.isSellable = isSellable
        item.ingredients = ingredients
        if isComposite {
            // composto não tem estoque próprio
            item.quantity = 0
            item.minimumQuantity = 0
        } else {
            item.quantity = Double(quantityText.replacingOccurrences(of: ",", with: ".")) ?? 0
            item.minimumQuantity = Double(minimumQuantityText.replacingOccurrences(of: ",", with: ".")) ?? 0
        }
    }

    func updateItem() {
        guard let data = UserDefaults.standard.data(forKey: "items"),
              var items = try? JSONDecoder().decode([StockViewCellData].self, from: data) else { return }
        applyFields()
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
