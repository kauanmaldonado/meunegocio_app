//
//  StockView.swift
//  MeuNegocio
//

import SwiftUI

// MARK: StockView
struct StockView: View {

    @StateObject var viewModel = StockViewModel()
    @StateObject var filterViewModel = FilterViewModel()

    @State var showAddProduct: Bool = false
    @State var showFilter: Bool = false

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

    // Lista com busca + filtros aplicados
    private var displayItems: [StockViewCellData] {
        let searched = viewModel.fetchItems()
        return filterViewModel.apply(to: searched)
    }

    // MARK: Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            StockListView(
                items: $viewModel.items,
                searchItems: displayItems,
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showFilter = true } label: {
                        Image(systemName: filterViewModel.isActive
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                            .foregroundStyle(Color.color111827)
                    }
                }
            }
            .sheet(isPresented: $showFilter) {
                FilterView(filterViewModel: filterViewModel)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
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
