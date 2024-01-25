import ComposableArchitecture
import Hoods
import SwiftUI

struct RootView: View {
    @State var currentPath: Path?

    enum Path {
        case keychainUI
    }

    var body: some View {
        NavigationSplitView {
            List {
                Button("KeychainUI") {
                    currentPath = .keychainUI
                }
            }
        } detail: {
            switch currentPath {
            case .keychainUI:
                KeychainUIView(
                    store: Store(initialState: KeychainUIFeature.State()) {
                        KeychainUIFeature()
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
