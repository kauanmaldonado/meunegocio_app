//
//  AddProductViewModel.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 27/03/25.
//

import SwiftUI

class AddProductViewModel: ObservableObject {

    @Published var item = StockViewCellData()

    @Published var isShowingSourcePicker = false
    @Published var isShowingImagePicker: Bool = false
    @Published var isShowingQRScanner: Bool = false
    
    @Published var unitCostText: String = ""
    @Published var unitPriceText: String = ""
    @Published var quantityText: String = ""
    @Published var minimumQuantityText: String = ""

    @Published var unit: StockViewCellData.Unit = .un

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

    func saveImageToDocuments(_ image: UIImage, named name: String)  {
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
        let doubleValue = (Double(digits) ?? 0) / 100
        
        return doubleValue
    }

    func applyCurrencyMask(to value: String) -> String {
        let digits = value.filter { "0123456789".contains($0) }
        let doubleValue = (Double(digits) ?? 0) / 100

        // Atualiza o modelo com o valor numérico real
        item.unitCost = doubleValue

        return Self.formatToCurrencyString(doubleValue)
    }

    static func formatToCurrencyString(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }
}
