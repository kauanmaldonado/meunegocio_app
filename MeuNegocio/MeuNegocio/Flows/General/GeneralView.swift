//
//  GeneralView.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 09/02/25.
//

import SwiftUI

// MARK: - Models (exemplo)
struct LowStockItem: Identifiable {

    let id = UUID()
    let name: String
    let current: Int
    let minimum: Int

    var ratio: Double {
        guard minimum > 0 else { return 0 }
        return min(max(Double(current) / Double(minimum), 0), 1)
    }

    var isOutOfStock: Bool { current <= 0 }
}

// MARK: - GeneralView
struct GeneralView: View {

    @StateObject private var vm = GeneralViewModel()

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        if let image = gradientImage() { appearance.backgroundImage = image }
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        List {
            
            // ALERTAS
            Section {
                LowStockCard(items: vm.lowStock) {
                    print("ir para tela de estoque baixo")
                }
            }
            .padding(.top, 10)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.colorF3F4F6)

        }
        .listStyle(.plain)
        .background(Color.colorF3F4F6)
        .navigationTitle("Geral")
        .toolbarTitleDisplayMode(.large)
        .onAppear { vm.load(date: vm.selectedDate) }
        .onChange(of: vm.selectedDate) { _, newValue in
            vm.load(date: newValue)
        }
    }

    // MARK: Private
    private static func gradientImage() -> UIImage? {
        let size = CGSize(width: UIScreen.main.bounds.width, height: 120)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let colors = [
                UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1.0).cgColor,
                UIColor(red: 0.07, green: 0.10, blue: 0.15, alpha: 1.0).cgColor
            ]
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: [0, 1]
            )!
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: size.width / 2, y: 0),
                end: CGPoint(x: size.width / 2, y: size.height),
                options: []
            )
        }
    }

    private func gradientImage() -> UIImage? { Self.gradientImage() }
}

// MARK: - Cards
struct LowStockCard: View {

    let items: [StockViewCellData]
    let onTap: () -> Void

    private var outOfStockCount: Int {
        items.filter { $0.stockLevel == .exhausted }.count
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.color111827)
                    .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 8)

                VStack(alignment: .leading, spacing: 14) {

                    // Header
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.10))
                                .frame(width: 38, height: 38)

                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Estoque baixo")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)

                            Text("Itens abaixo do mínimo configurado")
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.68))
                        }

                        Spacer()

                        // Badge contagem
                        HStack(spacing: 8) {
                            Text("\(items.count)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.10))
                        .clipShape(Capsule())
                    }

                    // Summary chips
                    HStack(spacing: 10) {
                        SummaryPill(title: "Atenção", value: "\(items.count)")
                        SummaryPill(title: "Zerados", value: "\(outOfStockCount)")
                    }

                    // List preview (top 3)
                    VStack(spacing: 10) {
                        ForEach(items.prefix(2)) { item in
                            LowStockRow(item: item)
                        }
                    }

                    // Footer CTA
                    HStack {
                        Text("Ver todos")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.92))

                        Spacer().frame(width: 16)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.75))
                        
                        Spacer()
                    }
                    .padding(.top, 2)
                }
                .padding(16)
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.colorF3F4F6)
    }
}

// MARK: - Components

private struct SummaryPill: View {
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

private struct LowStockRow: View {

    let item: StockViewCellData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                
                // status dot
                Circle()
                    .fill(item.stockLevel == .exhausted ? Color.white.opacity(0.95) : Color.white.opacity(0.35))
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.productName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text("\(item.quantity) em estoque • mínimo \(item.minimumQuantity)")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.65))
                }
                
                Spacer()
                
                // small badge
                Text(item.stockLevel == .exhausted ? "SEM" : "BAIXO")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(item.stockLevel == .exhausted ? 0.16 : 0.10))
                    .clipShape(Capsule())
            }
            
            // ratio bar (current / minimum)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(item.stockLevel == .exhausted ? 0.90 : 0.55))
                        .frame(width: geo.size.width * item.ratio, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
