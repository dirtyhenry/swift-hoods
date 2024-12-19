import ComposableArchitecture
import Hoods
import SwiftUI

struct RootView: View {
    @State var currentPath: Path?
    @State private var preferredColumn = NavigationSplitViewColumn.detail

    static let counterStore = Store(initialState: CounterFeature.State()) {
        CounterFeature()
            ._printChanges()
    }

    func navigate(to path: Path) {
        currentPath = path
        preferredColumn = .detail
    }

    enum Path: String {
        case keychainUI
        case mailer
        case copyText
        case imagePicker
        case tcaCounter
    }

    var body: some View {
        NavigationSplitView(preferredCompactColumn: $preferredColumn) {
            List {
                Button("KeychainUI") { navigate(to: .keychainUI) }
                Button("Mailer") { navigate(to: .mailer) }
                Button("CopyText") { navigate(to: .copyText) }
                Button("ImagePicker") { navigate(to: .imagePicker) }
                Button("TCA Counter") { navigate(to: .tcaCounter) }
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
            case .copyText:
                CopyTextDemoView(
                    store: Store(initialState: CopyTextDemoFeature.State()) {
                        CopyTextDemoFeature()
                    }
                )
            case .imagePicker:
                ImagePickerDemoView(
                    store: Store(initialState: ImagePickerDemoFeature.State()) {
                        ImagePickerDemoFeature()
                    }
                )
            case .tcaCounter:
                CounterView(store: Self.counterStore)
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
