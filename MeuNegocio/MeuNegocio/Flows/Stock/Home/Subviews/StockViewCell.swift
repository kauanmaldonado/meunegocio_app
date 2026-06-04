//
//  StockViewCell.swift
//  MeuNegocio
//

import SwiftUI

struct StockViewCell: View {

    let model: StockViewCellData
    let isLast: Bool
    var allItems: [StockViewCellData] = []
    var onDetails: () -> Void = {}
    var onEdit: () -> Void = {}
    var onRestock: () -> Void = {}

    private let accentBlue = Color(red: 0.25, green: 0.55, blue: 0.95)

    // Borda colorida quando o estoque exige atenção
    private var borderColor: Color {
        if model.isComposite {
            // Composto só fica vermelho se faltar algum ingrediente
            return model.availableUnits(in: allItems) <= 0 ? Color.colorEF4444 : Color.clear
        }
        switch model.stockLevel {
        case .exhausted: return Color.colorEF4444
        case .lowStock:  return Color.colorEAB308
        case .goodStock: return Color.clear
        }
    }

    private var marginText: String? {
        let cost = model.resolvedUnitCost(in: allItems)
        guard cost > 0 else { return nil }
        let margin = ((model.unitPrice - cost) / cost) * 100
        return "\(Int(margin.rounded()))%"
    }

    var body: some View {
        ZStack {
            Color(Color.colorF3F4F6)

            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.color6B7280.opacity(0.1), radius: 4, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(borderColor, lineWidth: borderColor == .clear ? 0 : 1.5)
                )

            VStack(alignment: .leading, spacing: 10) {

                HStack(alignment: .top, spacing: 14) {

                    // Imagem (tamanho fixo, preenchida)
                    productImage

                    // Dados do produto
                    VStack(alignment: .leading, spacing: 4) {

                        HStack(alignment: .top) {
                            Text(model.productName)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color.color111827)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer()

                            Button { onEdit() } label: {
                                Image(systemName: "pencil")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(accentBlue)
                                    .frame(width: 30, height: 30)
                                    .background(accentBlue.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.borderless)
                        }

                        if model.isSellable {
                            Text("SKU: \(model.code)")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.color6B7280)
                        }

                        if model.isSellable {
                            // Preço + margem (produto vendável)
                            HStack(spacing: 8) {
                                Text(model.unitPrice.toCurrency())
                                    .font(.system(size: 19, weight: .bold))
                                    .foregroundStyle(accentBlue)

                                if let marginText {
                                    Text("Lucro \(marginText)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(Color.color22C55E)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.color22C55E.opacity(0.12))
                                        .clipShape(Capsule())
                                }
                            }
                        } else {
                            // Insumo (não vendável): mostra o custo médio
                            HStack(spacing: 6) {
                                Text("Custo:")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.color6B7280)
                                Text(model.unitCost.toCurrency())
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundStyle(Color.color111827)
                                Text("insumo")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.color6B7280)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(Color.color6B7280.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }

                        // Status
                        statusRow
                            .padding(.top, 2)
                    }
                }

                // Rodapé
                HStack {
                    HStack(spacing: 4) {
                        Text("Ver detalhes")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(red: 0.10, green: 0.15, blue: 0.25))

                    Spacer()

                    if !model.isComposite {
                        Button { onRestock() } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Repor")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .frame(height: 34)
                            .background(Color.color111827)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .padding(14)
        }
        .contentShape(Rectangle())
        .onTapGesture { onDetails() }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.colorF3F4F6)
    }

    // MARK: - Subviews

    private var productImage: some View {
        ZStack {
            if let uiImage = UIImage(contentsOfFile: model.productURLImage), !model.productURLImage.isEmpty {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image("placeholder")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            }
        }
        .frame(width: 90, height: 90)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.color6B7280.opacity(0.2), lineWidth: 0.5))
    }

    @ViewBuilder
    private var statusRow: some View {
        if model.isComposite {
            let available = model.availableUnits(in: allItems)
            HStack(spacing: 8) {
                if available <= 0 {
                    Text("Esgotado")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.colorEF4444)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.colorEF4444.opacity(0.14))
                        .clipShape(Capsule())
                }
                HStack(spacing: 6) {
                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.system(size: 11))
                    Text("Composto • \(available.formatted(.number.precision(.fractionLength(0...2)))) disp.")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(Color.color6B7280)
            }
        } else {
            HStack(spacing: 8) {
                Text(model.stockLevel.title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(model.stockLevel.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(model.stockLevel.color.opacity(0.14))
                    .clipShape(Capsule())

                Text("\(model.quantity.formatted(.number.precision(.fractionLength(0...2)))) \(model.unit.rawValue)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.color111827)
            }
        }
    }
}
