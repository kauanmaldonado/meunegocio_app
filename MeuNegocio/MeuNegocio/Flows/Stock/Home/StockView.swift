//
//  StockView.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 09/02/25.
//

import SwiftUI

// MARK: StockView
struct StockView: View {

    // MARK: Variables
    @StateObject var viewModel = StockViewModel()

    @State var showAddProduct: Bool = false
    @State var showDetailProduct: Bool = false

    // MARK: Initializers
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.96, alpha: 1.0)
        let titleColor = UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1.0)
        appearance.largeTitleTextAttributes = [.foregroundColor: titleColor]
        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        if let searchBarTextField = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]) as? UITextField {
            searchBarTextField.backgroundColor = UIColor.white
            searchBarTextField.layer.cornerRadius = 10
            searchBarTextField.clipsToBounds = true
        }
    }

    // MARK: Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            StockListView(
                items: $viewModel.items,
                searchItems: viewModel.searchResults,
                searchQuery: viewModel.searchQuery,
                onDismissDetail: {
                    viewModel.loadItems()
                    viewModel.fetchSearchResults()
                }
            )
                .searchable(
                    text: $viewModel.searchQuery,
                    isPresented: $viewModel.searchIsActive,
                    placement: .toolbar,
                    prompt: "Digite o nome do produto"
                )
                .padding(.bottom, -120)
                .textInputAutocapitalization(.never)
                .onChange(of: viewModel.searchQuery) {
                    viewModel.fetchSearchResults()
                }
                .onChange(of: showAddProduct) { isPresented in
                    if !isPresented {
                        viewModel.loadItems()
                        viewModel.fetchSearchResults()
                    }
                }

            StockNewButtonView {
                showAddProduct.toggle()
            }
            .padding(.bottom, 70)
            .sheet(isPresented: $showAddProduct) {
                AddProductView()
                    .presentationDragIndicator(.hidden)
            }
            .onAppear {
                viewModel.loadItems()
            }
        }
        .navigationTitle("Estoque")
        .toolbarTitleDisplayMode(.large)
        .foregroundStyle(Color.blue)
    }

}

#Preview {
    StockView()
}
