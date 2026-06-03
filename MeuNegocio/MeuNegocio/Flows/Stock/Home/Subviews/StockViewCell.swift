//
//  StockViewCell.swift
//  MeuNegocio
//

import SwiftUI

struct StockViewCell: View {

    @State private var isShowingPicker = false

    let model: StockViewCellData
    let isLast: Bool
    var onDelete: () -> Void = {}
    var onDetails: () -> Void = {}
    var onEdit: () -> Void = {}
    var onIncrement: () -> Void = {}
    var onDecrement: () -> Void = {}

    private var quantityStep: Double {
        model.unit == .un ? 1 : 0.1
    }

    var body: some View {
        ZStack {
            Color(Color.colorF3F4F6)

            RoundedRectangle(cornerRadius: 18)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white)
                        .shadow(color: Color.color6B7280.opacity(0.1), radius: 4, x: 0, y: 2)
                )

            VStack(alignment: .leading, spacing: 8) {

                // Topo: imagem + dados + botões
                HStack(alignment: .top) {

                    // Imagem
                    VStack {
                        let path = model.productURLImage
                        if let uiImage = UIImage(contentsOfFile: path) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 85, height: 100)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.color6B7280, lineWidth: 0.2))
                        } else {
                            Image("placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 90, height: 105)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.color6B7280, lineWidth: 0.2))
                        }
                        Spacer()
                    }

                    Spacer().frame(width: 16)

                    // Dados do produto
                    VStack(alignment: .leading) {
                        Text(model.productName)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.custom("Inter", fixedSize: 22))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.color111827)
                            .padding(.bottom, 1)

                        Text("SKU: \(model.code)")
                            .font(.custom("Inter", fixedSize: 14))
                            .fontWeight(.regular)
                            .padding(.trailing)
                            .foregroundStyle(Color.color6B7280)

                        Spacer().frame(height: 8)

                        Text("\(model.unitPrice.toCurrency())")
                            .font(.custom("Inter", fixedSize: 20))
                            .foregroundStyle(Color(red: 0.25, green: 0.55, blue: 0.95))
                            .fontWeight(.bold)
                            .padding(.trailing)

                        StockViewCellQuantity(quantity: model.quantity, stockLevel: model.stockLevel)
                    }

                    Spacer()

                    // Botões: editar + lixeira
                    VStack(spacing: 8) {
                        Button { onEdit() } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(Color(red: 0.25, green: 0.55, blue: 0.95))
                        }
                        .buttonStyle(.borderless)

                        Button { isShowingPicker = true } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.top, 4)
                    .padding(.trailing, 4)
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)

                // Rodapé: "Ver detalhes" + controle +/−
                HStack {
                    Button { onDetails() } label: {
                        HStack(spacing: 4) {
                            Text("Ver detalhes")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(red: 0.10, green: 0.15, blue: 0.25))
                        .padding(.top, 6)
                    }
                    .buttonStyle(.borderless)

                    Spacer()

                    // Controle rápido de quantidade
                    HStack(spacing: 0) {
                        Button { onDecrement() } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 13, weight: .bold))
                                .frame(width: 30, height: 30)
                                .foregroundStyle(model.quantity > 0 ? Color.color111827 : Color.color6B7280)
                                .background(Color.colorF3F4F6)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.borderless)

                        Text(model.unit == .un
                             ? "\(Int(model.quantity))"
                             : String(format: "%.1f", model.quantity))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.color111827)
                            .frame(minWidth: 34)
                            .multilineTextAlignment(.center)

                        Button { onIncrement() } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .bold))
                                .frame(width: 30, height: 30)
                                .foregroundStyle(.white)
                                .background(Color.color111827)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding(.leading, 15)
                .padding(.trailing, 12)
                .padding(.bottom, 15)
            }
        }
        .sheet(isPresented: $isShowingPicker) {
            DeleteItemPicker {
                isShowingPicker = false
                onDelete()
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.colorF3F4F6)
    }
}
