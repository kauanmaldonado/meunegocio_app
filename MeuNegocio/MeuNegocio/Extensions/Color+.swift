//
//  Color+.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 03/03/25.
//

import SwiftUI

extension Color {

    // MARK: Public Methods
    static func fromHex(_ hex: String) -> Color {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized.replacingOccurrences(of: "#", with: "")).scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        return Color(red: red, green: green, blue: blue)
    }

    static let colorFFFFFF = Color.fromHex("FFFFFF")
    static let color9CA3AF = Color.fromHex("FFFFFF")
    static let color4B5563 = Color.fromHex("4B5563")
    static let color6B7280 = Color.fromHex("6B7280")
    static let color2563EB = Color.fromHex("25632E")
    static let color000000 = Color.fromHex("000000")
    static let color111827 = Color.fromHex("111827")
    static let colorE5E7EB = Color.fromHex("E5E7EB")
    static let color22C55E = Color.fromHex("22C55E")
    static let colorF3F4F6 = Color.fromHex("F3F4F6")
    static let colorF9FAFB = Color.fromHex("F9FAFB")
    static let colorEF4444 = Color.fromHex("EF4444")
    static let colorEAB308 = Color.fromHex("EAB308")
}
