//
//  StockViewCell.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 14/02/25.
//

import SwiftUI

struct StockViewCell: View {
    
    @State private var isShowingPicker = false
    @State private var isShowingDetail = false
    
    let model: StockViewCellData
    let isLast: Bool
    var onDelete: () -> Void = {}
    var onDetails: () -> Void = {}
    
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
                HStack(alignment: .top) {
                    
                    // Imagem
                    VStack {
                        let path = model.productURLImage
                        if let uiImage = UIImage(contentsOfFile: path) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 85, height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.color6B7280, lineWidth: 0.2)
                                )
                        } else {
                            Image("placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 90, height: 105)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.color6B7280, lineWidth: 0.2)
                                        .shadow(color: Color.color6B7280, radius: 1, x: 0, y: 0)
                                )
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
                    
                    // Botão de lixeira
                    Button(action: { }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(.top, 4)
                            .padding(.trailing, 4)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .onTapGesture {
                    isShowingPicker = true
                }
                
                // Botão detalhes
                HStack {                    
                    Button {
                        onDetails()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Ver detalhes")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color(red: 0.10, green: 0.15, blue: 0.25))
                        .padding(.top, 6)
                    }
                    Spacer()
                }
                .padding(.leading, 15)
                .padding(.bottom, 15)
                .onTapGesture {
                    onDetails()
                }
            }
        }
        .contentShape(Rectangle()) // Área clicável do card
        .onTapGesture {
            print("Card")
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

struct DeleteItemPicker: View {
    
    var onSelect: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Deseja excluir o produto?")
                .font(.headline)
                .padding(.top)
                .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))
            
            Button(action: {
                onSelect()
                dismiss()
            }) {
                Label("Excluir", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(Color.colorF3F4F6)
                    .background(Color(red: 0.10, green: 0.15, blue: 0.25))
                    .cornerRadius(12)
            }
            
            Button(action: {
                dismiss()
            }) {
                Text("Cancelar")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
        .cornerRadius(20)
        .presentationDetents([.fraction(0.20)])
        .presentationDragIndicator(.visible)
    }
}
