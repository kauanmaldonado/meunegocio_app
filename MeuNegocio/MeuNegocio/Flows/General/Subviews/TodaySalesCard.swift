//
//  TodaySalesCard.swift
//  MeuNegocio
//

import SwiftUI

struct TodaySalesCard: View {

    @ObservedObject var vm: GeneralViewModel

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
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Vendas de hoje")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("Resumo do dia atual")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.68))
                    }
                    Spacer()
                }

                HStack(spacing: 10) {
                    DashPill(title: "Total",   value: vm.todayTotal.toCurrency())
                    DashPill(title: "Vendas",  value: "\(vm.todayCount)")
                    DashPill(title: "Ticket",  value: vm.todayTicketAvg.toCurrency())
                }
            }
            .padding(16)
        }
    }
}

struct DashPill: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
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
