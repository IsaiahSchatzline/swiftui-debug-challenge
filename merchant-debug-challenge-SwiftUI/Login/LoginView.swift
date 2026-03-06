import SwiftUI

struct LoginView: View {
    @Binding var path: [AppRoute]
    @StateObject private var viewModel: LoginViewModel

    init(merchant: Merchant, path: Binding<[AppRoute]>) {
        _path = path
        _viewModel = StateObject(wrappedValue: LoginViewModel(merchant: merchant))
    }

    var body: some View {
        Form {
            Section {
                TextField("Username", text: $viewModel.username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                SecureField("Password", text: $viewModel.password)

                Toggle("Require OTP", isOn: $viewModel.requireOTP)
            }

            Section {
                Button("Log In") {
                    if let route = viewModel.loginTapped() {
                        path.append(route)
                    }
                }
                .frame(maxWidth: .infinity)
            }

            if let errorText = viewModel.errorText {
                Section {
                    Text(errorText)
                        .foregroundStyle(.red)
                }
            }

            if viewModel.showOTPEntry {
                Section("OTP Required") {
                    TextField("Enter OTP (1234)", text: $viewModel.otpCode)
                        .keyboardType(.numberPad)

                    Button("Submit OTP") {
                        if let route = viewModel.submitOTPTapped() {
                            path.append(route)
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.title)
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
    }
}
