//
//  SellView.swift
//  MeuNegocio
//

import SwiftUI

// MARK: - DateFilter

enum DateFilter: Equatable {
    case none
    case singleDay(Date)
    case range(start: Date, end: Date)

    var isActive: Bool { self != .none }

    var summaryLabel: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "pt_BR")
        switch self {
        case .none:
            return "Vendas de hoje"
        case .singleDay(let d):
            fmt.dateFormat = "dd/MM/yyyy"
            return fmt.string(from: d)
        case .range(let s, let e):
            fmt.dateFormat = "dd/MM/yy"
            return "\(fmt.string(from: s)) – \(fmt.string(from: e))"
        }
    }

    var summarySubLabel: String {
        switch self {
        case .none:    return "Resumo do dia atual"
        case .singleDay: return "Filtro por dia"
        case .range:   return "Filtro por período"
        }
    }
}

// MARK: - SellView

struct SellView: View {

    @StateObject private var sellViewModel = SellViewModel()
    @StateObject private var stockViewModel = StockViewModel()
    @State private var showNewSale = false
    @State private var showCalendar = false
    @State private var dateFilter: DateFilter = .none

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

    private var filteredGroups: [(title: String, total: Double, sales: [Sale])] {
        let calendar = Calendar.current
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.dateFormat = "dd 'de' MMMM 'de' yyyy"

        switch dateFilter {
        case .none:
            return sellViewModel.groupedSales

        case .singleDay(let date):
            let filtered = sellViewModel.sales.filter { calendar.isDate($0.date, inSameDayAs: date) }
            guard !filtered.isEmpty else { return [] }
            return [(fmt.string(from: date).capitalized, filtered.reduce(0) { $0 + $1.total }, filtered)]

        case .range(let start, let end):
            let startDay = calendar.startOfDay(for: start)
            let endDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end) ?? end
            let filtered = sellViewModel.sales.filter { $0.date >= startDay && $0.date <= endDay }
            guard !filtered.isEmpty else { return [] }

            // Agrupa por dia dentro do período
            var byDay: [Date: [Sale]] = [:]
            for sale in filtered {
                let day = calendar.startOfDay(for: sale.date)
                byDay[day, default: []].append(sale)
            }
            return byDay.keys.sorted(by: >).map { day in
                let sales = byDay[day]!
                return (fmt.string(from: day).capitalized, sales.reduce(0) { $0 + $1.total }, sales)
            }
        }
    }

    private var summaryTotal: Double { filteredGroups.reduce(0) { $0 + $1.total } }
    private var summaryCount: Int    { filteredGroups.reduce(0) { $0 + $1.sales.count } }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {
                Section {
                    DailySummaryCard(
                        label: dateFilter.summaryLabel,
                        subLabel: dateFilter.summarySubLabel,
                        total: summaryTotal,
                        count: summaryCount,
                        isFiltered: dateFilter.isActive
                    )
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.colorF3F4F6)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))

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
                    .frame(height: 130)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.colorF3F4F6)
            }
            .listStyle(.plain)
            .background(Color.colorF3F4F6)
            .scrollIndicators(.hidden)
            .padding(.bottom, -120)

            StockNewButtonView { showNewSale = true }
                .padding(.bottom, 70)
                .sheet(isPresented: $showNewSale, onDismiss: {
                    sellViewModel.loadSales()
                    stockViewModel.loadItems()
                }) {
                    NewSaleView(stockViewModel: stockViewModel, sellViewModel: sellViewModel)
                        .presentationDragIndicator(.hidden)
                }
        }
        .navigationTitle("Vendas")
        .toolbarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showCalendar = true } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "calendar")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(Color.color111827)
                        if dateFilter.isActive {
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
        .sheet(isPresented: $showCalendar) {
            CalendarFilterSheet(filter: $dateFilter)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Subviews

    private var emptyView: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 40)
            Image(systemName: dateFilter.isActive ? "calendar.badge.exclamationmark" : "rectangle.portrait.on.rectangle.portrait")
                .font(.system(size: 44))
                .foregroundStyle(Color.color6B7280.opacity(0.5))
            Text(dateFilter.isActive ? "Sem vendas neste período" : "Nenhuma venda registrada")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.color6B7280)
            Text(dateFilter.isActive ? "Tente selecionar outro período" : "Toque em Nova Venda para começar")
                .font(.system(size: 13))
                .foregroundStyle(Color.color6B7280.opacity(0.7))
            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.colorF3F4F6)
    }


}

// MARK: - CalendarFilterSheet

private struct CalendarFilterSheet: View {

    @Binding var filter: DateFilter
    @Environment(\.dismiss) var dismiss

    enum FilterMode: String, CaseIterable {
        case day = "Dia"
        case range = "Período"
    }

    @State private var mode: FilterMode = .day
    @State private var singleDate: Date = Date()
    @State private var startDate: Date = Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date()
    @State private var endDate: Date = Date()

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack {
                Text("Filtrar por data")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.color111827)
                Spacer()
                if filter.isActive {
                    Button("Limpar") {
                        filter = .none
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(red: 0.25, green: 0.55, blue: 0.95))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)

            // Segmented picker
            Picker("Modo", selection: $mode) {
                ForEach(FilterMode.allCases, id: \.self) {
                    Text($0.rawValue).tag($0)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            ScrollView(showsIndicators: false) {
                if mode == .day {
                    dayPicker
                } else {
                    rangePicker
                }
            }

            // Botão aplicar
            Button {
                applyFilter()
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
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.colorF3F4F6.ignoresSafeArea())
        .onAppear { syncFromFilter() }
    }

    // MARK: Pickers

    private var dayPicker: some View {
        DatePicker("", selection: $singleDate, in: ...Date(), displayedComponents: .date)
            .datePickerStyle(.graphical)
            .tint(Color.color111827)
            .padding(.horizontal, 12)
    }

    private var rangePicker: some View {
        VStack(spacing: 16) {
            // De
            VStack(alignment: .leading, spacing: 8) {
                Text("De")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.color6B7280)
                    .padding(.horizontal, 4)

                DatePicker("", selection: $startDate, in: ...endDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Color.color111827)
                    .padding(.horizontal, 4)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.color6B7280.opacity(0.08), radius: 4, x: 0, y: 2)
            }

            // Até
            VStack(alignment: .leading, spacing: 8) {
                Text("Até")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.color6B7280)
                    .padding(.horizontal, 4)

                DatePicker("", selection: $endDate, in: startDate...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Color.color111827)
                    .padding(.horizontal, 4)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.color6B7280.opacity(0.08), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    // MARK: Helpers

    private func applyFilter() {
        if mode == .day {
            filter = .singleDay(singleDate)
        } else {
            filter = .range(start: startDate, end: endDate)
        }
    }

    private func syncFromFilter() {
        switch filter {
        case .none:
            mode = .day
            singleDate = Date()
        case .singleDay(let d):
            mode = .day
            singleDate = d
        case .range(let s, let e):
            mode = .range
            startDate = s
            endDate = e
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

                Divider().background(Color.colorE5E7EB)

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
