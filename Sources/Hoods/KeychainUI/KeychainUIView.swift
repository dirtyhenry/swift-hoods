import Blocks
import ComposableArchitecture
import SwiftUI

public struct KeychainUIView: View {
    let store: StoreOf<KeychainUIFeature>

    public init(store: StoreOf<KeychainUIFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                if viewStore.items.isEmpty {
                    VStack {
                        Text("No keychain items were found.")
                    }
                } else {
                    List {
                        ForEach(viewStore.items) { item in
                            VStack(alignment: .leading) {
                                Text(item.itemClass?.description ?? "n/a")
                                    .font(.caption)
                                HStack {
                                    Text(item.account)
                                    Spacer()
                                    Text(format(secret: item.secret))
                                }
                                Text(item.rawProps?.description ?? "n/a")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                if let errorMessage = viewStore.errorMessage {
                    Text(errorMessage)
                }
            }
            .navigationTitle("Issues")
            .toolbar {
                ToolbarItem {
                    Button {
                        viewStore.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(
                store: store.scope(
                    state: \.$destination,
                    action: \.destination
                ),
                state: /KeychainUIFeature.Destination.State.addKeychainItem,
                action: KeychainUIFeature.Destination.Action.addKeychainItem
            ) { addKeychainItemStore in
                NavigationView {
                    AddKeychainItemView(store: addKeychainItemStore)
                }
            }
            .onAppear {
                viewStore.send(.listKeychainItemsButtonTapped)
            }
        }
    }

    func format(secret: Data?) -> String {
        guard let secret else {
            return "🔐"
        }

        if let string = String(data: secret, encoding: .utf8) {
            return string
        }

        return DataFormatter.hexadecimalString(from: secret)
    }
}

@available(macOS 13.0, *)
@available(iOS 16.0, *)
struct KeychainUIView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            KeychainUIView(store: Store(
                initialState: KeychainUIFeature.State()
            ) { KeychainUIFeature() }
            )
        }
    }
}
