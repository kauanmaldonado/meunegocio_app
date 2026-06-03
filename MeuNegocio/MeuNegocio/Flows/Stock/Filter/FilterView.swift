//
//  FilterView.swift
//  MeuNegocio
//

import SwiftUI

struct FilterView: View {

    @ObservedObject var filterViewModel: FilterViewModel
    @Environment(\.dismiss) var dismiss

    @State private var minQtyText: String = ""
    @State private var maxQtyText: String = ""

    private let brandGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.10, green: 0.15, blue: 0.25),
            Color(red: 0.07, green: 0.10, blue: 0.15)
        ]),
        startPoint: .top, endPoint: .bottom
    )

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack {
                Text("Filtros")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.color111827)
                Spacer()
                if filterViewModel.isActive {
                    Button("Limpar") {
                        filterViewModel.reset()
                        minQtyText = ""
                        maxQtyText = ""
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(red: 0.25, green: 0.55, blue: 0.95))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // Seção: Status do estoque
                    sectionTitle("Status do estoque")
                    HStack(spacing: 10) {
                        ForEach([StockViewCellData.StockLevel.exhausted, .lowStock, .goodStock], id: \.title) { level in
                            let selected = filterViewModel.selectedLevels.contains(level)
                            Button {
                                if selected {
                                    filterViewModel.selectedLevels.remove(level)
                                } else {
                                    filterViewModel.selectedLevels.insert(level)
                                }
                            } label: {
                                Text(level.title)
                                    .font(.system(size: 13, weight: selected ? .bold : .regular))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selected ? Color.color111827 : Color.colorF3F4F6)
                                    .foregroundStyle(selected ? Color.white : Color.color6B7280)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().stroke(
                                            selected ? Color.clear : Color.colorE5E7EB,
                                            lineWidth: 1
                                        )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Seção: Ordenação
                    sectionTitle("Ordenação")
                    VStack(spacing: 0) {
                        ForEach(SortOption.allCases) { option in
                            Button {
                                filterViewModel.sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                        .font(.system(size: 15))
                                        .foregroundStyle(Color.color111827)
                                    Spacer()
                                    if filterViewModel.sortOption == option {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(Color(red: 0.25, green: 0.55, blue: 0.95))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)

                            if option != SortOption.allCases.last {
                                Divider().padding(.horizontal, 16)
                            }
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color.color6B7280.opacity(0.08), radius: 4, x: 0, y: 2)

                    // Seção: Faixa de quantidade
                    sectionTitle("Faixa de quantidade")
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Mínimo")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.color6B7280)
                            TextField("0", text: $minQtyText)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 15))
                                .padding(12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(color: Color.color6B7280.opacity(0.08), radius: 3, x: 0, y: 1)
                                .onChange(of: minQtyText) { v in
                                    filterViewModel.minQty = Double(v.replacingOccurrences(of: ",", with: ".")) ?? 0
                                }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Máximo")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.color6B7280)
                            TextField("9999", text: $maxQtyText)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 15))
                                .padding(12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(color: Color.color6B7280.opacity(0.08), radius: 3, x: 0, y: 1)
                                .onChange(of: maxQtyText) { v in
                                    filterViewModel.maxQty = Double(v.replacingOccurrences(of: ",", with: ".")) ?? 9999
                                }
                        }
                    }

                    if filterViewModel.minQty > filterViewModel.maxQty {
                        Text("O mínimo não pode ser maior que o máximo")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.colorEF4444)
                    }

                    Spacer().frame(height: 8)
                }
                .padding(.horizontal, 20)
            }

            // Botão Aplicar
            Button {
                dismiss()
            } label: {
                Text("Aplicar")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(brandGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.colorF3F4F6.ignoresSafeArea())
        .onAppear {
            if filterViewModel.minQty > 0 { minQtyText = String(filterViewModel.minQty) }
            if filterViewModel.maxQty < 9999 { maxQtyText = String(filterViewModel.maxQty) }
        }
    }

    @ViewBuilder
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Color.color6B7280)
    }
}

#Preview {
    FilterView(filterViewModel: FilterViewModel())
}
