//
//  AddProduct.swift
//  MeuNegocio
//
//  Created by Amador Maldonado, Kauan on 09/03/25.
//
 
import SwiftUI

private let brandGradient = LinearGradient(
    gradient: Gradient(colors: [
        Color(red: 0.10, green: 0.15, blue: 0.25),
        Color(red: 0.07, green: 0.10, blue: 0.15)
    ]),
    startPoint: .top,
    endPoint: .bottom
)

struct AddProductView: View {

    @Environment(\.dismiss) var dismiss
    @ObservedObject private var viewModel: AddProductViewModel

    @State private var productImage: UIImage? = nil
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showIngredientPicker: Bool = false

    init(editing product: StockViewCellData? = nil) {
        if let product = product {
            _viewModel = ObservedObject(wrappedValue: AddProductViewModel(editing: product))
        } else {
            _viewModel = ObservedObject(wrappedValue: AddProductViewModel())
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(Color.colorF3F4F6).ignoresSafeArea()

                VStack(spacing: 0) {
                    scrollContent
                    addButton
                }
            }
        }
    }

    // MARK: - Partes extraídas

    private var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Spacer().frame(height: 40)
                header
                imagePickerSection
                Spacer().frame(height: 12)
                nameSection
                codeSection
                sellableSection
                ingredientsSection
                pricingSection
                if !viewModel.isComposite {
                    quantitySection
                    unitSection
                }
                Spacer().frame(height: 80)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }

    private var header: some View {
        Text(viewModel.mode == .add ? "Novo Produto" : "Editar Produto")
            .foregroundStyle(brandGradient)
            .font(.system(size: 30, weight: .bold))
            .padding(.bottom, 10)
    }

    @ViewBuilder
    private var imagePickerSection: some View {
        AddImageButton(selectedImage: $productImage) {
            viewModel.isShowingSourcePicker = true
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .sheet(isPresented: $viewModel.isShowingSourcePicker) {
            ImageSourcePicker { source in
                imageSourceType = (source == .camera) ? .camera : .photoLibrary
                viewModel.isShowingSourcePicker = false
                viewModel.isShowingImagePicker = true
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowingImagePicker) {
            ImagePicker(selectedImage: $productImage, sourceType: imageSourceType)
        }
    }

    @ViewBuilder
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Nome do produto")
            HStack {
                Image(systemName: "highlighter")
                    .foregroundStyle(.gray)
                TextField("Insira o nome", text: $viewModel.item.productName)
                    .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    private var codeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Código do produto")
            HStack {
                Image(systemName: "highlighter")
                    .foregroundStyle(.gray)
                TextField("Insira o código", text: $viewModel.item.code)
                    .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))

                Spacer()

                Image(systemName: "barcode.viewfinder")
                    .foregroundStyle(.black)
                    .onTapGesture { viewModel.isShowingQRScanner.toggle() }
                    .sheet(isPresented: $viewModel.isShowingQRScanner) {
                        QRCodeScannerView(
                            scannedCode: $viewModel.item.code,
                            isPresented: $viewModel.isShowingQRScanner
                        )
                    }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }

    // Custo só faz sentido quando o produto tem estoque próprio (não composto).
    // Preço só faz sentido quando o produto é vendável.
    private var showCost: Bool { !viewModel.isComposite }
    private var showPrice: Bool { viewModel.isSellable }

    @ViewBuilder
    private var pricingSection: some View {
        if showCost || showPrice {
            VStack(spacing: 12) {
                SectionHeader(title: "Precificação", horizontalAlignment: .center)
                HStack(spacing: 20) {
                    if showCost {
                        StepperTextField(
                            label: "Custo",
                            textFieldText: "R$ 0,00",
                            valueText: $viewModel.unitCostText
                        )
                        .onChange(of: viewModel.unitCostText) { newValue in
                            viewModel.unitCostText = viewModel.applyCurrencyMask(to: newValue)
                        }
                    }

                    if showPrice {
                        StepperTextField(
                            label: "Preço",
                            textFieldText: "R$ 0,00",
                            valueText: $viewModel.unitPriceText
                        )
                        .onChange(of: viewModel.unitPriceText) { newValue in
                            viewModel.unitPriceText = viewModel.applyPriceMask(to: newValue)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var sellableSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vendável")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))
                    Text("Aparece na tela de venda")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
                Spacer()
                Toggle("", isOn: $viewModel.isSellable)
                    .labelsHidden()
                    .tint(Color(red: 0.25, green: 0.55, blue: 0.95))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Ficha técnica (ingredientes)")

            if viewModel.ingredients.isEmpty {
                Text("Sem ingredientes — é um produto simples. Adicione ingredientes para torná-lo composto (ex: caipirinha).")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                    .padding(.bottom, 4)
            }

            ForEach(viewModel.ingredients) { ing in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ing.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))
                        Text("\(ing.quantityPerUnit.formatted(.number.precision(.fractionLength(0...3)))) por unidade")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                    Button {
                        viewModel.removeIngredient(ing)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.borderless)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }

            Button {
                showIngredientPicker = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Adicionar ingrediente")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(red: 0.25, green: 0.55, blue: 0.95))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(12)
            }
            .sheet(isPresented: $showIngredientPicker) {
                IngredientPickerView(products: viewModel.existingProducts) { product, qty in
                    viewModel.addIngredient(product, quantityPerUnit: qty)
                }
            }
        }
    }

    @ViewBuilder
    private var quantitySection: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Quantidade", horizontalAlignment: .center)

            HStack(spacing: 20) {
                StepperTextField(
                    label: "Atual",
                    textFieldText: "0",
                    valueText: $viewModel.quantityText
                )
                .keyboardType(viewModel.unit == .un ? .numberPad : .decimalPad)

                StepperTextField(
                    label: "Mínima",
                    textFieldText: "0",
                    valueText: $viewModel.minimumQuantityText
                )
                .keyboardType(viewModel.unit == .un ? .numberPad : .decimalPad)
            }
        }
    }

    @ViewBuilder
    private var unitSection: some View {
        VStack(spacing: 12) {
            SectionHeader(title: "Unidade", horizontalAlignment: .center)

            Picker("Unidade", selection: $viewModel.unit) {
                ForEach(StockViewCellData.Unit.allCases) { unit in
                    Text(unit.title).tag(unit)
                }
            }
            .pickerStyle(.palette)
            .padding(8)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }

    private var addButton: some View {
        Button {
            if let image = productImage {
                let id = UUID().uuidString
                viewModel.saveImageToDocuments(image, named: id)
            }
            if viewModel.mode == .add {
                viewModel.saveItems()
            } else {
                viewModel.updateItem()
            }
            dismiss()
        } label: {
            Text(viewModel.mode == .add ? "Adicionar" : "Salvar alterações")
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundStyle(.white)
                .font(.system(size: 18, weight: .bold))
                .background(brandGradient)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }
    }
}


struct SectionHeader: View {

    let title: String
    let horizontalAlignment: HorizontalAlignment

    init(
        title: String,
        horizontalAlignment: HorizontalAlignment = .leading
    ) {
        self.title = title
        self.horizontalAlignment = horizontalAlignment
    }

    var body: some View {
        VStack(alignment: horizontalAlignment) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))
                .padding(.bottom, 3)
        }
    }
}

struct StepperTextField: View {

    let label: String

    var textFieldText: String
    @Binding var valueText: String

    var step: Int = 1

    var body: some View {
        VStack(alignment: .center, spacing: 6) {

            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.10, green: 0.15, blue: 0.25))

            HStack() {
                TextField(textFieldText, text: $valueText)
                    .foregroundStyle(Color(red: 0.10, green: 0.15, blue: 0.25))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(height: 40)
                    .background(Color.white)
                    .cornerRadius(6)
                    
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

#Preview {
    AddProductView()
}
