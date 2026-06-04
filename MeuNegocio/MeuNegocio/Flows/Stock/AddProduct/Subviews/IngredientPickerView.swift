//
//  IngredientPickerView.swift
//  MeuNegocio
//

import SwiftUI

struct IngredientPickerView: View {

    let products: [StockViewCellData]
    let onAdd: (StockViewCellData, Double) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var selected: StockViewCellData? = nil
    @State private var quantityText: String = ""
    @State private var searchQuery: String = ""

    private var filtered: [StockViewCellData] {
        let q = searchQuery.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return products }
        return products.filter {
            $0.productName.lowercased().contains(q) || $0.code.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Busca
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.color6B7280)
                    TextField("Buscar produto", text: $searchQuery)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.top, 12)

                if products.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(filtered) { product in
                            Button {
                                selected = product
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(product.productName)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundStyle(Color.color111827)
                                        Text("Estoque: \(product.quantity.formatted(.number.precision(.fractionLength(0...2)))) \(product.unit.rawValue)")
                                            .font(.system(size: 12))
                                            .foregroundStyle(Color.color6B7280)
                                    }
                                    Spacer()
                                    if selected?.id == product.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color(red: 0.25, green: 0.55, blue: 0.95))
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.colorF3F4F6)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.colorF3F4F6)
                }

                // Quantidade + adicionar
                if let selected = selected {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Quantidade por unidade (\(selected.unit.rawValue))")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.color6B7280)
                            Spacer()
                        }
                        TextField("0", text: $quantityText)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Button {
                            let qty = Double(quantityText.replacingOccurrences(of: ",", with: ".")) ?? 0
                            guard qty > 0 else { return }
                            onAdd(selected, qty)
                            dismiss()
                        } label: {
                            Text("Adicionar ingrediente")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [
                                        Color(red: 0.10, green: 0.15, blue: 0.25),
                                        Color(red: 0.07, green: 0.10, blue: 0.15)
                                    ]), startPoint: .top, endPoint: .bottom)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(16)
                    .background(Color.colorF3F4F6)
                }
            }
            .background(Color.colorF3F4F6.ignoresSafeArea())
            .navigationTitle("Adicionar ingrediente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: "cube.box")
                .font(.system(size: 40))
                .foregroundStyle(Color.color6B7280.opacity(0.5))
            Text("Cadastre os insumos primeiro")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.color6B7280)
            Spacer()
        }
    }
}
