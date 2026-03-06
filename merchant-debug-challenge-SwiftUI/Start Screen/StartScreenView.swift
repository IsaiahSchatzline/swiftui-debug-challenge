import SwiftUI
import Combine

/*
 CardSwitcher Demo mirrors real mock CardSwitcher integration at a high level:
 1) Create a 30-minute session before opening the flow.
 2) Emit SDK-like events during merchant selection and login.
 3) After AUTHENTICATED, generate a taskId and submit a mock POST /card switch.
 4) Persist selected card by merchant+account and handle session refresh requests.
 */
enum AppRoute: Hashable {
    case merchants
    case login(Merchant)
    case card(merchant: Merchant, accountId: String, taskId: String)
    case logs
}

struct StartScreenView: View {
    @StateObject private var viewModel = StartScreenViewModel()

    private let ticker = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            VStack(spacing: 16) {
                Spacer()

                Text("CardSwitcher Demo")
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(viewModel.sessionStatusText)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Start") {
                    viewModel.startTapped()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

                Button("Create Session") {
                    viewModel.createSessionTapped()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)

                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logs") {
                        viewModel.logsTapped()
                    }
                }
            }
            .alert("Create session first", isPresented: $viewModel.showSessionAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please create a session before starting.")
            }
            .alert("Session Created", isPresented: $viewModel.showCreateSessionConfirmation) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Mock 30-minute session is now active.")
            }
            .onAppear {
                viewModel.onAppear()
            }
            .onDisappear {
                viewModel.onDisappear()
            }
            .onReceive(ticker) { value in
                viewModel.tick(value)
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .merchants:
                    MerchantPickerView(path: $viewModel.path)
                case .login(let merchant):
                    LoginView(merchant: merchant, path: $viewModel.path)
                case .card(let merchant, let accountId, let taskId):
                    CardPickerView(merchant: merchant, accountId: accountId, taskId: taskId, path: $viewModel.path)
                case .logs:
                    EventLogView()
                }
            }
        }
    }
}
