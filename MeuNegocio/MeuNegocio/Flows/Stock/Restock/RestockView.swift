//
//  RestockView.swift
//  MeuNegocio
//

import SwiftUI

struct RestockView: View {

    let product: StockViewCellData
    let onConfirm: (_ quantity: Double, _ unitCostPaid: Double) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var quantityText: String = ""
    @State private var costText: String = ""

    private let brandGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.10, green: 0.15, blue: 0.25),
            Color(red: 0.07, green: 0.10, blue: 0.15)
        ]),
        startPoint: .top, endPoint: .bottom
    )

    // Valor de referência: última reposição, senão o custo atual
    private var referenceCost: Double {
        product.lastRestockCost ?? product.unitCost
    }

    private var enteredCost: Double {
        let digits = costText.filter { "0123456789".contains($0) }
        return (Double(digits) ?? 0) / 100
    }

    private var enteredQuantity: Double {
        Double(quantityText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private var variation: Double {
        guard referenceCost > 0, enteredCost > 0 else { return 0 }
        return ((enteredCost - referenceCost) / referenceCost) * 100
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    header
                    quantityField
                    costField

                    if enteredCost > 0 {
                        comparisonBox
                    }

                    if !product.restocks.isEmpty {
                        historySection
                    }

                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .background(Color.colorF3F4F6.ignoresSafeArea())
            .navigationTitle("Repor estoque")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                confirmButton
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 4) {
            Text(product.productName)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.color111827)
            Text("Em estoque: \(product.quantity.formatted(.number.precision(.fractionLength(0...2)))) \(product.unit.rawValue) • custo médio \(product.unitCost.toCurrency())")
                .font(.system(size: 13))
                .foregroundStyle(Color.color6B7280)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
    }

    private var quantityField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quantidade adicionada (\(product.unit.rawValue))")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.color6B7280)
            TextField("0", text: $quantityText)
                .keyboardType(product.unit == .un ? .numberPad : .decimalPad)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
        }
    }

    private var costField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Valor pago por unidade")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.color6B7280)
            TextField("R$ 0,00", text: $costText)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .onChange(of: costText) { _ in
                    costText = formatCurrency(enteredCost)
                }
        }
    }

    private var comparisonBox: some View {
        let up = variation > 0
        let flat = abs(variation) < 0.01
        let color: Color = flat ? Color.color6B7280 : (up ? Color.colorEF4444 : Color.color22C55E)
        let icon = flat ? "equal.circle.fill" : (up ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
        let refLabel = product.lastRestockCost != nil ? "última compra" : "custo atual"

        return HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(flat ? "Mesmo valor da \(refLabel)"
                          : (up ? "Mais caro que a \(refLabel)" : "Mais barato que a \(refLabel)"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.color111827)
                Text("\(referenceCost.toCurrency()) → \(enteredCost.toCurrency())  (\(String(format: "%+.1f", variation))%)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.color6B7280)
            }
            Spacer()
        }
        .padding(14)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Histórico de reposições")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.color6B7280)

            ForEach(product.restocks.reversed()) { restock in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dateText(restock.date))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.color111827)
                        Text("+\(restock.quantity.formatted(.number.precision(.fractionLength(0...2)))) \(product.unit.rawValue)")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.color6B7280)
                    }
                    Spacer()
                    Text(restock.unitCostPaid.toCurrency())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.color111827)
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var confirmButton: some View {
        Button {
            guard enteredQuantity > 0, enteredCost > 0 else { return }
            onConfirm(enteredQuantity, enteredCost)
            dismiss()
        } label: {
            Text("Confirmar reposição")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(brandGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .opacity(enteredQuantity > 0 && enteredCost > 0 ? 1 : 0.5)
        }
        .disabled(enteredQuantity <= 0 || enteredCost <= 0)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.colorF3F4F6)
    }

    // MARK: - Helpers

    private func formatCurrency(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "pt_BR")
        return f.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    private func dateText(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "dd/MM/yyyy 'às' HH:mm"
        return f.string(from: date)
    }
}
