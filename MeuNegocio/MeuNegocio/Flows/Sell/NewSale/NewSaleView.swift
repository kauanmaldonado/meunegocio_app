//
//  NewSaleView.swift
//  MeuNegocio
//

import SwiftUI

private let brandGradient = LinearGradient(
    gradient: Gradient(colors: [
        Color(red: 0.10, green: 0.15, blue: 0.25),
        Color(red: 0.07, green: 0.10, blue: 0.15)
    ]),
    startPoint: .top,
    endPoint: .bottom
)

struct NewSaleView: View {

    @Environment(\.dismiss) var dismiss
    @ObservedObject var stockViewModel: StockViewModel
    @ObservedObject var sellViewModel: SellViewModel

    @State private var cart: [UUID: Double] = [:]
    @State private var showConfirmation = false
    @State private var searchQuery: String = ""
    @State private var isShowingScanner = false
    @State private var scannedCode: String = ""

    private var filteredItems: [StockViewCellData] {
        let query = searchQuery.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return stockViewModel.items }
        return stockViewModel.items.filter {
            $0.productName.lowercased().contains(query) ||
            $0.code.lowercased().contains(query)
        }
    }

    private var cartItems: [StockViewCellData] {
        stockViewModel.items.filter { (cart[$0.id] ?? 0) > 0 }
    }

    private var cartTotal: Double {
        cartItems.reduce(0) { $0 + $1.unitPrice * (cart[$1.id] ?? 0) }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.colorF3F4F6.ignoresSafeArea()

                VStack(spacing: 0) {
                    searchBar
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                    if stockViewModel.items.isEmpty {
                        emptyState
                    } else if filteredItems.isEmpty {
                        noResultsState
                    } else {
                        productList
                    }
                }

                if !cartItems.isEmpty {
                    confirmBar
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Nova Venda")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.color111827)
                }
            }
            .onAppear {
                stockViewModel.loadItems()
            }
            .onChange(of: scannedCode) { code in
                guard !code.isEmpty else { return }
                searchQuery = code
                scannedCode = ""
            }
            .sheet(isPresented: $isShowingScanner) {
                QRCodeScannerView(scannedCode: $scannedCode, isPresented: $isShowingScanner)
            }
            .alert("Confirmar venda?", isPresented: $showConfirmation) {
                Button("Confirmar", role: .none) { finalizeSale() }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Total: \(cartTotal.toCurrency())")
            }
        }
    }

    // MARK: - Subviews

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(Color.color6B7280)

            TextField("Buscar por nome ou código", text: $searchQuery)
                .font(.system(size: 15))
                .foregroundStyle(Color.color111827)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.color6B7280)
                }
                .buttonStyle(.borderless)
            }

            Divider()
                .frame(height: 20)
                .background(Color.colorE5E7EB)

            Button {
                isShowingScanner = true
            } label: {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.color111827)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.color6B7280.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private var productList: some View {
        List {
            ForEach(filteredItems) { product in
                ProductCartRow(
                    product: product,
                    quantity: Binding(
                        get: { cart[product.id] ?? 0 },
                        set: { cart[product.id] = $0 }
                    )
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.colorF3F4F6)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }

            Spacer()
                .frame(height: 100)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.colorF3F4F6)
        }
        .listStyle(.plain)
        .background(Color.colorF3F4F6)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "cube.box")
                .font(.system(size: 48))
                .foregroundStyle(Color.color6B7280)
            Text("Nenhum produto no estoque")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.color6B7280)
            Spacer()
        }
    }

    private var noResultsState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(Color.color6B7280.opacity(0.5))
            Text("Nenhum produto encontrado")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.color6B7280)
            Text("Tente outro nome ou código")
                .font(.system(size: 13))
                .foregroundStyle(Color.color6B7280.opacity(0.7))
            Spacer()
        }
    }

    private var confirmBar: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(cartItems.count) \(cartItems.count == 1 ? "item" : "itens")")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.7))
                    Text(cartTotal.toCurrency())
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

                Spacer()

                Button {
                    showConfirmation = true
                } label: {
                    Text("Confirmar Venda")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(brandGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: -4)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Actions

    private func finalizeSale() {
        let saleItems = cartItems.compactMap { product -> SaleItem? in
            guard let qty = cart[product.id], qty > 0 else { return nil }
            return SaleItem(
                productId: product.id,
                productName: product.productName,
                quantity: qty,
                unitPrice: product.unitPrice
            )
        }
        guard !saleItems.isEmpty else { return }
        sellViewModel.registerSale(items: saleItems, stockViewModel: stockViewModel)
        dismiss()
    }
}

// MARK: - ProductCartRow

private struct ProductCartRow: View {

    let product: StockViewCellData
    @Binding var quantity: Double

    @State private var quantityText: String = ""
    @FocusState private var isFocused: Bool

    private func syncTextFromQuantity() {
        quantityText = quantity == 0 ? "" : quantity.formatted(.number.precision(.fractionLength(0...2)))
    }

    private func updateQuantityFromText(_ newValue: String) {
        let normalized = newValue.replacingOccurrences(of: ",", with: ".")
        var value = Double(normalized) ?? 0
        if value < 0 { value = 0 }
        if product.unit == .un { value = value.rounded(.down) }
        if value > product.quantity { value = product.quantity }
        quantity = value
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.color6B7280.opacity(0.1), radius: 4, x: 0, y: 2)

            HStack(spacing: 14) {

                // Imagem
                ZStack {
                    if let uiImage = UIImage(contentsOfFile: product.productURLImage), !product.productURLImage.isEmpty {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipped()
                    } else {
                        Image("placeholder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.color6B7280.opacity(0.2), lineWidth: 0.5))

                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(product.productName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.color111827)
                        .lineLimit(1)

                    Text(product.unitPrice.toCurrency())
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(red: 0.25, green: 0.55, blue: 0.95))

                    Text("Estoque: \(product.quantity.formatted(.number.precision(.fractionLength(0...2)))) \(product.unit.rawValue)")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.color6B7280)
                }

                Spacer()

                // Stepper
                HStack(spacing: 0) {
                    Button {
                        if quantity > 0 { quantity -= 1 }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(quantity > 0 ? Color.color111827 : Color.color6B7280)
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.borderless)

                    TextField("0", text: $quantityText)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.color111827)
                        .frame(minWidth: 36)
                        .multilineTextAlignment(.center)
                        .keyboardType(product.unit == .un ? .numberPad : .decimalPad)
                        .focused($isFocused)
                        .onChange(of: quantityText) { newValue in
                            updateQuantityFromText(newValue)
                        }
                        .onChange(of: quantity) { _ in
                            if !isFocused { syncTextFromQuantity() }
                        }
                        .onChange(of: isFocused) { focused in
                            if !focused { syncTextFromQuantity() }
                        }
                        .onAppear { syncTextFromQuantity() }
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Concluir") { isFocused = false }
                            }
                        }

                    Button {
                        if quantity < product.quantity { quantity += 1 }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(quantity < product.quantity ? Color.color111827 : Color.color6B7280)
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.borderless)
                }
                .background(Color.colorF3F4F6)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(14)
        }
    }
}
