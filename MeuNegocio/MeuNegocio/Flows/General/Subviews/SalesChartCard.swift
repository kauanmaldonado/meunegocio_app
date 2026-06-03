//
//  SalesChartCard.swift
//  MeuNegocio
//

import SwiftUI
import Charts

struct SalesChartCard: View {

    @ObservedObject var vm: GeneralViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.color6B7280.opacity(0.1), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 14) {

                // Header
                HStack {
                    Text("Faturamento")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.color111827)
                    Spacer()
                    Text(periodTotal.toCurrency())
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.color111827)
                }

                // Chips de período
                HStack(spacing: 8) {
                    ForEach(ChartPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue)
                            .font(.system(size: 12, weight: vm.chartPeriod == period ? .bold : .regular))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(vm.chartPeriod == period ? Color.color111827 : Color.colorF3F4F6)
                            .foregroundStyle(vm.chartPeriod == period ? Color.white : Color.color6B7280)
                            .clipShape(Capsule())
                            .onTapGesture { vm.chartPeriod = period }
                    }
                }

                // Gráfico
                if vm.chartData.isEmpty {
                    Text("Sem dados no período")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.color6B7280)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 140)
                } else {
                    Chart(vm.chartData, id: \.date) { point in
                        BarMark(
                            x: .value("Dia", point.date, unit: .day),
                            y: .value("Total", point.total)
                        )
                        .foregroundStyle(point.total > 0 ? Color.color111827 : Color.colorE5E7EB)
                        .cornerRadius(4)
                    }
                    .chartXAxis {
                        AxisMarks(values: xAxisValues) { value in
                            AxisValueLabel {
                                if let date = value.as(Date.self) {
                                    Text(xLabel(for: date))
                                        .font(.system(size: 10))
                                        .foregroundStyle(Color.color6B7280)
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let v = value.as(Double.self) {
                                    Text(abbreviated(v))
                                        .font(.system(size: 10))
                                        .foregroundStyle(Color.color6B7280)
                                }
                            }
                            AxisGridLine(stroke: StrokeStyle(dash: [3]))
                                .foregroundStyle(Color.colorE5E7EB)
                        }
                    }
                    .frame(height: 140)
                }
            }
            .padding(16)
        }
    }

    // MARK: - Helpers

    private var periodTotal: Double {
        vm.chartData.reduce(0) { $0 + $1.total }
    }

    private var xAxisValues: [Date] {
        guard !vm.chartData.isEmpty else { return [] }
        let count = vm.chartData.count
        // Mostra no máximo 5 labels para não sobrecarregar
        let step = max(1, count / 5)
        return stride(from: 0, to: count, by: step).compactMap {
            $0 < vm.chartData.count ? vm.chartData[$0].date : nil
        }
    }

    private let xFmt: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "dd/MM"
        return f
    }()

    private func xLabel(for date: Date) -> String {
        xFmt.string(from: date)
    }

    private func abbreviated(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.0fk", value / 1000)
        }
        return String(format: "%.0f", value)
    }
}
