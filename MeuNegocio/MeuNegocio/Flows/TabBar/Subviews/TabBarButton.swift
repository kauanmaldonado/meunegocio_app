//
//  TabBarButton.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 27/03/25.
//

import SwiftUI

struct TabBarButton: View {

    var imageName: String
    var label: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        VStack(alignment: .center) {

            Image(systemName: imageName)
                .font(.system(size: 18))

            Text(label)
                .font(.footnote)

            if isSelected {
                Circle()
                    .frame(width: 3, height: 3)
                    .foregroundColor(.white)
                    .padding(.top, 1.5)
            }
        }
        .padding(.vertical, 10)
        .onTapGesture {
            action()
        }
        .foregroundColor(isSelected ? Color(red: 1.00, green: 0.40, blue: 0.00) : .white)
    }
}
