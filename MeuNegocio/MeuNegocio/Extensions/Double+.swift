//
//  Double+.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 03/03/25.
//

import Foundation

extension Double {

    func toCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR") // Define o formato do Brasil (R$)

        return formatter.string(from: NSNumber(value: self)) ?? "R$ 0,00"
    }

    func toPercent(decimalPlaces: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = decimalPlaces
        formatter.maximumFractionDigits = decimalPlaces
        formatter.locale = Locale(identifier: "pt_BR")
        
        // Se o valor for > 1, assumimos que já está em "percentual inteiro"
        let normalizedValue = self > 1 ? self / 100 : self
        
        return formatter.string(from: NSNumber(value: normalizedValue)) ?? "0%"
    }
}
