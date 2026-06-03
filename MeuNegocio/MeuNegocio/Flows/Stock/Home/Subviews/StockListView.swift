//
//  StockListView.swift
//  MeuNegocio
//

import SwiftUI

struct StockListView: View {

    @State private var selectedItem: StockViewCellData? = nil
    @State private var editingItem: StockViewCellData? = nil

    @Binding var items: [StockViewCellData]

    let searchItems: [StockViewCellData]
    let searchQuery: String
    let onDismissDetail: () -> Void

    var body: some View {
        VStack {
            let displayItems: [StockViewCellData] = (!searchItems.isEmpty && !searchQuery.isEmpty)
                ? searchItems
                : (searchQuery.isEmpty ? items : [])

            if searchQuery.isEmpty || !searchItems.isEmpty {
                List(displayItems.indices, id: \.self) { index in
                    let item = displayItems[index]
                    let isLast = index == displayItems.count - 1
                    let isFirst = index == 0

                    StockViewCell(
                        model: item,
                        isLast: false,
                        onDelete: {
                            items.removeAll { $0.code == item.code && $0.productName == item.productName }
                        },
                        onDetails: { selectedItem = item },
                        onEdit: { editingItem = item },
                        onIncrement: {
                            if let idx = items.firstIndex(where: { $0.code == item.code }) {
                                let step = items[idx].unit == .un ? 1.0 : 0.1
                                items[idx].quantity += step
                            }
                        },
                        onDecrement: {
                            if let idx = items.firstIndex(where: { $0.code == item.code }) {
                                let step = items[idx].unit == .un ? 1.0 : 0.1
                                items[idx].quantity = max(0, items[idx].quantity - step)
                            }
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
        .sheet(item: $selectedItem, onDismiss: { onDismissDetail() }) { item in
            DetailView(viewModel: .init(code: item.code))
                .presentationDragIndicator(.hidden)
        }
        .sheet(item: $editingItem, onDismiss: { onDismissDetail() }) { item in
            AddProductView(editing: item)
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
