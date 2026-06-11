//
//  StockListView.swift
//  MeuNegocio
//

import SwiftUI

struct StockListView: View {

    @State private var selectedItem: StockViewCellData? = nil
    @State private var editingItem: StockViewCellData? = nil
    @State private var restockingItem: StockViewCellData? = nil
    @State private var deletingItem: StockViewCellData? = nil

    @Binding var items: [StockViewCellData]

    let searchItems: [StockViewCellData]
    let searchQuery: String
    let onDismissDetail: () -> Void

    var body: some View {
        VStack {
            // searchItems já vem com busca + filtros aplicados pelo StockView
            let displayItems = searchItems

            if !displayItems.isEmpty {
                List(displayItems.indices, id: \.self) { index in
                    let item = displayItems[index]
                    let isLast = index == displayItems.count - 1
                    let isFirst = index == 0

                    StockViewCell(
                        model: item,
                        isLast: false,
                        allItems: items,
                        onDetails: { selectedItem = item },
                        onEdit: { editingItem = item },
                        onRestock: { restockingItem = item }
                    )
                    .padding(.bottom, isLast ? 130 : 8)
                    .padding(.top, isFirst ? 8 : 0)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deletingItem = item
                        } label: {
                            Label("Excluir", systemImage: "trash")
                        }
                    }
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
            DetailView(viewModel: .init(productId: item.id))
                .presentationDragIndicator(.hidden)
        }
        .sheet(item: $editingItem, onDismiss: { onDismissDetail() }) { item in
            AddProductView(editing: item)
                .presentationDragIndicator(.hidden)
        }
        .sheet(item: $deletingItem) { item in
            DeleteItemPicker {
                items.removeAll { $0.id == item.id }
            }
        }
        .sheet(item: $restockingItem) { item in
            RestockView(product: item) { quantity, unitCostPaid in
                if let idx = items.firstIndex(where: { $0.id == item.id }) {
                    items[idx].applyRestock(quantity: quantity, unitCostPaid: unitCostPaid)
                }
            }
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
