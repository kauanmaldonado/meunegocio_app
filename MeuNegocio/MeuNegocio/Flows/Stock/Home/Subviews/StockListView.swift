//
//  StockListView.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 27/03/25.
//

import SwiftUI

struct StockListView: View {

    @State private var isShowingSourcePicker = false
    @State private var selectedItem: StockViewCellData? = nil

    @Binding var items: [StockViewCellData]

    let searchItems: [StockViewCellData]
    let searchQuery: String
    let onDismissDetail: () -> Void

    var body: some View {
        VStack {
            if searchItems.isEmpty && searchQuery.isEmpty {
                List(items.indices, id: \.self) { index in
                    let item = items[index]
                    let isLast: Bool = index == items.count - 1
                    let isFirst: Bool = index == 0
                    
                    StockViewCell(
                        model: item,
                        isLast: false,
                        onDelete: {
                            items.removeAll { item.code == $0.code && item.productName == $0.productName }
                        },
                        onDetails: {
                            selectedItem = item
                        }
                    )
                    .padding(.bottom, isLast ? 130 : 8)
                    .padding(.top, isFirst ? 8 : 0)
                }
                .background(Color.colorF3F4F6)
                .listStyle(.plain)
                .scrollIndicators(.hidden)
            } else if !searchItems.isEmpty && !searchQuery.isEmpty {
                List(searchItems.indices, id: \.self) { index in
                        let item = searchItems[index]
                        let isLast: Bool = index == items.count - 1
                        let isFirst: Bool = index == 0

                        StockViewCell(
                            model: item,
                            isLast: false,
                            onDelete: {
                                items.removeAll { item.code == $0.code && item.productName == $0.productName }
                            },
                            onDetails: {
                                selectedItem = item
                            }
                        )
                        .padding(.bottom, isLast ? 130 : 8)
                        .padding(.top, isFirst ? 8 : 0)
                    }
                    .background(Color.colorF3F4F6)
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
            } else {
                List {
                    EmptyCell()
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.colorF3F4F6)
                }
                .background(Color.colorF3F4F6)
                .listStyle(.plain)
                .scrollIndicators(.hidden)
            }
        }
        .sheet(item: $selectedItem, onDismiss: {
            onDismissDetail()
        }) { item in
            DetailView(viewModel: .init(code: item.code))
                .presentationDragIndicator(.hidden)
        }
    }
}

struct EmptyCell: View {

    var body: some View {
        VStack(spacing: 16) {
            
            Text("Produto não foi encontrado")
                .frame(maxWidth: .infinity)
                .background(Color.colorF3F4F6)

            Image(systemName: "magnifyingglass")
                .frame(maxWidth: .infinity)
                .background(Color.colorF3F4F6)
            
            VStack {
                Text("Não há resultados")
                Text("Clique no botão + para adicionar um produto.")
            }
            .frame(maxWidth: .infinity)
            .background(Color.colorF3F4F6)
        }
        .padding(.top, 50)
        .background(Color.colorF3F4F6)
    }
}
