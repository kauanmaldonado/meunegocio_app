//
//  ProfitCard.swift
//  MeuNegocio
//

import SwiftUI

struct ProfitCard: View {

    @ObservedObject var vm: GeneralViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.color6B7280.opacity(0.1), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 14) {

                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.color22C55E.opacity(0.12))
                            .frame(width: 38, height: 38)
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.color22C55E)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Lucro estimado")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.color111827)
                        Text("Baseado nos custos cadastrados")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.color6B7280)
                    }
                    Spacer()
                }

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Lucro bruto")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.color6B7280)
                        Text(vm.todayProfit.toCurrency())
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(vm.todayProfit >= 0 ? Color.color22C55E : Color.colorEF4444)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Margem média")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.color6B7280)
                        Text(String(format: "%.1f%%", vm.todayAvgMargin))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(vm.todayAvgMargin >= 0 ? Color.color22C55E : Color.colorEF4444)
                    }
                }
            }
            .padding(16)
        }
    }
}
