//
//  SellView.swift
//  MeuNegocio
//

import SwiftUI

struct SellView: View {

    @StateObject private var sellViewModel = SellViewModel()
    @StateObject private var stockViewModel = StockViewModel()
    @State private var showNewSale = false
    @State private var showCalendar = false
    @State private var selectedDate: Date? = nil

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.96, alpha: 1.0)
        let titleColor = UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1.0)
        appearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    // Vendas filtradas pelo dia selecionado
    private var filteredGroups: [(title: String, total: Double, sales: [Sale])] {
        guard let date = selectedDate else { return sellViewModel.groupedSales }
        let calendar = Calendar.current
        let filtered = sellViewModel.sales.filter { calendar.isDate($0.date, inSameDayAs: date) }
        guard !filtered.isEmpty else { return [] }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd 'de' MMMM 'de' yyyy"
        let title = formatter.string(from: date).capitalized
        return [(title, filtered.reduce(0) { $0 + $1.total }, filtered)]
    }

    private var summaryTotal: Double {
        filteredGroups.reduce(0) { $0 + $1.total }
    }

    private var summaryCount: Int {
        filteredGroups.reduce(0) { $0 + $1.sales.count }
    }

    private var summaryLabel: String {
        guard let date = selectedDate else { return "Vendas de hoje" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }

    private var summarySubLabel: String {
        selectedDate == nil ? "Resumo do dia atual" : "Filtro aplicado"
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                // Card de resumo
                Section {
                    DailySummaryCard(
                        label: summaryLabel,
                        subLabel: summarySubLabel,
                        total: summaryTotal,
                        count: summaryCount,
                        isFiltered: selectedDate != nil
                    )
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.colorF3F4F6)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))

                // Histórico agrupado
                if filteredGroups.isEmpty {
                    Section {
                        emptyView
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.colorF3F4F6)
                } else {
                    ForEach(filteredGroups, id: \.title) { group in
                        Section {
                            ForEach(group.sales) { sale in
                                SaleCard(sale: sale)
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.colorF3F4F6)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                            .onDelete { offsets in
                                offsets.forEach { sellViewModel.deleteSale(group.sales[$0]) }
                            }
                        } header: {
                            PeriodHeader(title: group.title, total: group.total, count: group.sales.count)
                        }
                        .listRowBackground(Color.colorF3F4F6)
                    }
                }

                Spacer()
                    .frame(height: 80)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.colorF3F4F6)
            }
            .listStyle(.plain)
            .background(Color.colorF3F4F6)
            .scrollIndicators(.hidden)

            newSaleButton
                .padding(.bottom, 70)
        }
        .navigationTitle("Vendas")
        .toolbarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCalendar = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "calendar")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Color.color111827)

                        if selectedDate != nil {
                            Circle()
                                .fill(Color(red: 0.25, green: 0.55, blue: 0.95))
                                .frame(width: 8, height: 8)
                                .offset(x: 4, y: -4)
                        }
                    }
                }
            }
        }
        .onAppear {
            sellViewModel.loadSales()
            stockViewModel.loadItems()
        }
        .sheet(isPresented: $showNewSale, onDismiss: {
            sellViewModel.loadSales()
            stockViewModel.loadItems()
        }) {
            NewSaleView(stockViewModel: stockViewModel, sellViewModel: sellViewModel)
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showCalendar) {
            CalendarFilterSheet(selectedDate: $selectedDate)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Subviews

    private var emptyView: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 40)
            Image(systemName: selectedDate != nil ? "calendar.badge.exclamationmark" : "rectangle.portrait.on.rectangle.portrait")
                .font(.system(size: 44))
                .foregroundStyle(Color.color6B7280.opacity(0.5))
            Text(selectedDate != nil ? "Sem vendas nesta data" : "Nenhuma venda registrada")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.color6B7280)
            Text(selectedDate != nil ? "Tente selecionar outro dia" : "Toque em Nova Venda para começar")
                .font(.system(size: 13))
                .foregroundStyle(Color.color6B7280.opacity(0.7))
            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.colorF3F4F6)
    }

    private var newSaleButton: some View {
        Button {
            showNewSale = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                Text("Nova Venda")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.10, green: 0.15, blue: 0.25),
                        Color(red: 0.07, green: 0.10, blue: 0.15)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - CalendarFilterSheet

private struct CalendarFilterSheet: View {

    @Binding var selectedDate: Date?
    @Environment(\.dismiss) var dismiss

    @State private var pickerDate: Date = Date()

    var body: some View {
        VStack(spacing: 0) {

            // Handle + header
            HStack {
                Text("Filtrar por data")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.color111827)

                Spacer()

                if selectedDate != nil {
                    Button("Limpar") {
                        selectedDate = nil
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(red: 0.25, green: 0.55, blue: 0.95))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 8)

            // Calendário nativo
            DatePicker(
                "",
                selection: $pickerDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(Color.color111827)
            .padding(.horizontal, 12)

            // Botão aplicar
            Button {
                selectedDate = pickerDate
                dismiss()
            } label: {
                Text("Aplicar")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.10, green: 0.15, blue: 0.25),
                                Color(red: 0.07, green: 0.10, blue: 0.15)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(Color.colorF3F4F6)
        .onAppear {
            pickerDate = selectedDate ?? Date()
        }
    }
}

// MARK: - PeriodHeader

private struct PeriodHeader: View {

    let title: String
    let total: Double
    let count: Int

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.color111827)
                .textCase(nil)

            Spacer()

            Text("\(count) \(count == 1 ? "venda" : "vendas")")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.color6B7280)
                .textCase(nil)

            Text(total.toCurrency())
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.color111827)
                .textCase(nil)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .listRowInsets(EdgeInsets())
    }
}

// MARK: - DailySummaryCard

private struct DailySummaryCard: View {

    let label: String
    let subLabel: String
    let total: Double
    let count: Int
    let isFiltered: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.color111827)
                .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 8)

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 38, height: 38)
                        Image(systemName: isFiltered ? "calendar" : "chart.line.uptrend.xyaxis")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(label)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                        Text(subLabel)
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.68))
                    }

                    Spacer()
                }

                HStack(spacing: 10) {
                    SalesPill(title: "Total", value: total.toCurrency())
                    SalesPill(title: "Vendas", value: "\(count)")
                }
            }
            .padding(16)
        }
    }
}

private struct SalesPill: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.70))
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.10))
        .clipShape(Capsule())
    }
}

// MARK: - SaleCard

private struct SaleCard: View {

    let sale: Sale

    private var timeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: sale.date)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.color6B7280.opacity(0.1), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 10) {

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(timeText)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.color6B7280)
                        Text(sale.total.toCurrency())
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.color111827)
                    }

                    Spacer()

                    Text("\(sale.items.count) \(sale.items.count == 1 ? "item" : "itens")")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.color111827)
                        .clipShape(Capsule())
                }

                Divider()
                    .background(Color.colorE5E7EB)

                VStack(spacing: 4) {
                    ForEach(sale.items) { item in
                        HStack {
                            Text(item.productName)
                                .font(.system(size: 13))
                                .foregroundStyle(Color.color6B7280)
                                .lineLimit(1)
                            Spacer()
                            Text("x\(item.quantity.formatted(.number.precision(.fractionLength(0...2))))")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.color6B7280)
                            Text(item.total.toCurrency())
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.color111827)
                                .frame(minWidth: 70, alignment: .trailing)
                        }
                    }
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    SellView()
}
