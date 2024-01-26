import ComposableArchitecture
import Hoods
import SwiftUI

struct RootView: View {
    @State var currentPath: Path?
    @State private var preferredColumn = NavigationSplitViewColumn.detail

    func navigate(to path: Path) {
        currentPath = path
        preferredColumn = .detail
    }

    enum Path: String {
        case keychainUI
        case mailer
    }

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $preferredColumn) {
            List {
                Button("KeychainUI") { navigate(to: .keychainUI) }
                Button("Mailer") { navigate(to: .mailer) }
            }
        } detail: {
            switch currentPath {
            case .keychainUI:
                KeychainUIView(
                    store: Store(initialState: KeychainUIFeature.State()) {
                        KeychainUIFeature()
                    }
                )
            case .mailer:
                MailButtonDemoView(
                    store: Store(initialState: MailButtonDemoFeature.State()) {
                        MailButtonDemoFeature()
                    }
                )
            case nil:
                VStack {
                    Text("🏘️ Welcome to the ’hoods!")
                    Text("Please select a path.")
                }
            }
        }
    }
}

#Preview {
    RootView()
}
