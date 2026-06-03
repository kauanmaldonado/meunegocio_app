//
//  DeleteItemPicker.swift
//  MeuNegocio
//

import SwiftUI

struct DeleteItemPicker: View {

    var onSelect: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Deseja excluir o produto?")
                .font(.headline)
                .padding(.top)
                .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))

            Button(action: {
                onSelect()
                dismiss()
            }) {
                Label("Excluir", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(Color.colorF3F4F6)
                    .background(Color(red: 0.10, green: 0.15, blue: 0.25))
                    .cornerRadius(12)
            }

            Button(action: {
                dismiss()
            }) {
                Text("Cancelar")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
        .cornerRadius(20)
        .presentationDetents([.fraction(0.20)])
        .presentationDragIndicator(.visible)
    }
}
