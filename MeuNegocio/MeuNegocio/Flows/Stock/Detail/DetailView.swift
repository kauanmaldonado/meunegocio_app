//
//  DetailView.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 22/08/25.
//

import SwiftUI

enum EditableField: Identifiable {

    case productName
    case code
    case quantity
    case minimumQuantity
    case unitCost
    case unitPrice
    
    var id: String {
        String(describing: self)
    }
}

struct DetailView: View {

    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: DetailViewModel

    @State private var editingField: EditableField? = nil
    @State private var editedText: String = ""
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    headerSection
                    stockSection
                    pricingSection

                    if viewModel.item.isComposite {
                        recipeSection
                    } else if !viewModel.item.restocks.isEmpty {
                        restockHistorySection
                    }

                    Spacer().frame(height: 8)
                }
                .padding(.horizontal)
            }

            // MARK: - Botão Salvar no rodapé
            Button {
                viewModel.persistChanges()
                dismiss()
            } label: {
                Text("Salvar")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.10, green: 0.15, blue: 0.25),
                                Color(red: 0.07, green: 0.10, blue: 0.15)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(Color.colorF3F4F6.ignoresSafeArea())
        .navigationTitle("Detalhe do Produto")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.black)
                }
            }
        }
        .sheet(isPresented: $showDeleteConfirmation) {
            DeleteItemPicker {
                viewModel.deleteProduct()
                dismiss()
            }
        }
        .sheet(item: $editingField) { field in
            EditFieldView(
                field: field,
                text: $editedText,
                onSave: { newValue in
                    applyEdit(field: field, newValue: newValue)
                }
            )
            .presentationDetents([.height(170)])
        }
    }
    
    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 32)

            Text(viewModel.item.productName)
                .font(.title2).bold()
                .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))
                .multilineTextAlignment(.center)

            if viewModel.item.isSellable {
                Text("SKU: \(viewModel.item.code)")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }

            HStack(spacing: 8) {
                if viewModel.item.isComposite {
                    tag("Composto", system: "square.stack.3d.up.fill", color: Color(red: 0.25, green: 0.55, blue: 0.95))
                }
                if !viewModel.item.isSellable {
                    tag("Insumo", system: "shippingbox.fill", color: Color.color6B7280)
                }
            }
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private var stockSection: some View {
        SectionDetail(title: "Estoque") {
            if viewModel.item.isComposite {
                Card(name: "Disponível",
                     value: "\(fmt(viewModel.available)) un (dos ingredientes)")
                Card(name: "Status",
                     value: viewModel.isOutOfStock ? "Esgotado" : "Disponível",
                     valueColor: viewModel.isOutOfStock ? Color.colorEF4444 : Color.color22C55E)
            } else {
                Card(name: "Atual", value: "\(fmt(viewModel.item.quantity)) \(viewModel.item.unit.rawValue)") {
                    editingField = .quantity
                    editedText = fmt(viewModel.item.quantity)
                }
                Card(name: "Mínimo", value: "\(fmt(viewModel.item.minimumQuantity)) \(viewModel.item.unit.rawValue)") {
                    editingField = .minimumQuantity
                    editedText = fmt(viewModel.item.minimumQuantity)
                }
                Card(name: "Status",
                     value: viewModel.item.stockLevel.title,
                     valueColor: viewModel.item.stockLevel.color)
            }
        }
    }

    @ViewBuilder
    private var pricingSection: some View {
        SectionDetail(title: "Precificação") {
            if viewModel.item.isComposite {
                Card(name: "Custo (calculado dos ingredientes)",
                     value: viewModel.resolvedCost.toCurrency())
            } else {
                Card(name: "Custo médio", value: viewModel.item.unitCost.toCurrency()) {
                    editingField = .unitCost
                    editedText = viewModel.item.unitCost.brDecimalString
                }
            }

            if viewModel.item.isSellable {
                Card(name: "Preço de Venda", value: viewModel.item.unitPrice.toCurrency()) {
                    editingField = .unitPrice
                    editedText = viewModel.item.unitPrice.brDecimalString
                }
                Card(name: "Lucro / Unidade", value: viewModel.profit.toCurrency(),
                     valueColor: viewModel.profit >= 0 ? Color.color22C55E : Color.colorEF4444)
                Card(name: "Margem de Lucro", value: String(format: "%.0f%%", viewModel.margin),
                     valueColor: viewModel.margin >= 0 ? Color.color22C55E : Color.colorEF4444)
            }
        }
    }

    private var recipeSection: some View {
        SectionDetail(title: "Ficha técnica") {
            ForEach(viewModel.item.ingredients) { ing in
                let ingItem = ing.resolve(in: viewModel.allItems)
                let ingUnit = ingItem?.unit.rawValue ?? ""
                let contribution = (ingItem?.unitCost ?? 0) * ing.quantityPerUnit
                Card(name: ing.name,
                     value: "\(fmt(ing.quantityPerUnit)) \(ingUnit) • \(contribution.toCurrency())")
            }
        }
    }

    private var restockHistorySection: some View {
        SectionDetail(title: "Histórico de reposições") {
            ForEach(viewModel.item.restocks.reversed()) { restock in
                Card(name: dateText(restock.date),
                     value: "+\(fmt(restock.quantity)) \(viewModel.item.unit.rawValue) • \(restock.unitCostPaid.toCurrency())")
            }
        }
    }

    // MARK: - Helpers

    private func tag(_ text: String, system: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: system).font(.system(size: 10, weight: .bold))
            Text(text).font(.system(size: 12, weight: .bold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    private func fmt(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...2)))
    }

    private func dateText(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "dd/MM/yyyy 'às' HH:mm"
        return f.string(from: date)
    }

    private func applyEdit(field: EditableField, newValue: String) {
        switch field {
        case .productName:
            viewModel.item.productName = newValue
        case .code:
            viewModel.item.code = newValue
        case .quantity:
            if let v = newValue.brToDouble { viewModel.item.quantity = v }
        case .minimumQuantity:
            if let v = newValue.brToDouble { viewModel.item.minimumQuantity = v }
        case .unitCost:
            if let v = newValue.brToDouble { viewModel.item.unitCost = v }
        case .unitPrice:
            if let v = newValue.brToDouble { viewModel.item.unitPrice = v }
        }
    }
}


#Preview {
    DetailView(viewModel: .init(productId: UUID()))
}

// MARK: - Section
struct SectionDetail<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))
                .padding(.leading, 4)
            
            VStack(spacing: 10) {
                content
            }
        }
    }
}

// MARK: - Card
struct Card: View {
    let name: String
    let value: String
    var valueColor: Color = Color(red: 0.10, green: 0.15, blue: 0.25)
    var onEdit: (() -> Void)? = nil   // <- ação opcional
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.gray)
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(valueColor)
            }
            
            Spacer()
            
            if let onEdit = onEdit {
                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Editar")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.10, green: 0.15, blue: 0.25),
                                Color(red: 0.07, green: 0.10, blue: 0.15)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
}

struct EditFieldView: View {

    let field: EditableField
    @Binding var text: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            
            // Título centralizado
            Text(title(for: field))
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            
            // TextField igual AddProduct
            TextField("", text: $text)
                .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .frame(height: 40)
                .padding(.horizontal, 10)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.color6B7280.opacity(0.1), radius: 4, x: 1, y: 2)
                .focused($isFocused)
                .onAppear { DispatchQueue.main.async { self.isFocused = true } }

            // Botão Salvar
            Button {
                onSave(text)
                dismiss()
            } label: {
                Text("Salvar")
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .bold))
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.10, green: 0.15, blue: 0.25),
                                Color(red: 0.07, green: 0.10, blue: 0.15)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 20)
            }
        }
        .padding()
    }

    private func title(for field: EditableField) -> String {
        switch field {
        case .productName: return "Editar Nome do Produto"
        case .code: return "Editar Código"
        case .quantity: return "Editar Quantidade"
        case .minimumQuantity: return "Editar Quantidade Mínima"
        case .unitCost: return "Editar Preço de Compra"
        case .unitPrice: return "Editar Preço de Venda"
        }
    }
}


// MARK: - Botão de ação rápida
struct ActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        Button {
            // ação
        } label: {
            HStack {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 1)
        }
    }
}

extension NumberFormatter {
    static let decimalBR: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        return f
    }()
}

extension Double {
    /// Ex.: 1234.5 -> "1.234,5"
    var brDecimalString: String {
        NumberFormatter.decimalBR.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension String {
    /// Tenta converter "1.234,56", "1234,56", "R$ 1.234,56" em Double
    var brToDouble: Double? {
        // Remove tudo que não é dígito, vírgula ou ponto
        let cleaned = self
            .replacingOccurrences(of: "[^0-9,\\.]", with: "", options: .regularExpression)
        // Se tiver vírgula, ela é o separador decimal em pt-BR
        if cleaned.contains(",") {
            let normalized = cleaned.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: ".")
            return Double(normalized)
        } else {
            return Double(cleaned)
        }
    }
}
