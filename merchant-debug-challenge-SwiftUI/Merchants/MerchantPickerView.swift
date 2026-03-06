import SwiftUI

struct MerchantPickerView: View {
    @Binding var path: [AppRoute]
    @StateObject private var viewModel = MerchantPickerViewModel()

    var body: some View {
        List(viewModel.merchants, id: \.id) { merchant in
            Button {
                let route = viewModel.merchantTapped(merchant)
                path.append(route)
            } label: {
                HStack {
                    Text(merchant.name)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }
            }
            .foregroundStyle(.primary)
        }
        .navigationTitle("Pick Merchant")
    }
}
