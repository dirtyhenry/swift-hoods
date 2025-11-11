import Blocks
import ComposableArchitecture
import Foundation
import OSLog
import SwiftUI

let keychainUILogger = Logger(subsystem: "swift-hoods", category: "KeychainUI")

extension KeychainItem: Identifiable {
    public var id: String {
        account
    }
}

@Reducer
struct KeychainUIFeature {
    @ObservableState
    public struct State: Equatable {
        @Presents var destination: Destination.State?

        var items: [KeychainItem]
        var errorMessage: String?

        public init(items: [KeychainItem] = []) {
            self.items = items
        }
    }

    enum Action {
        case listKeychainItemsButtonTapped
        case addButtonTapped

        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.keychainGateway) var keychainGateway

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .listKeychainItemsButtonTapped:
                keychainUILogger.debug("Received action .listKeychainItemsButtonTapped")
                do {
                    state.items = try keychainGateway.listItems()
                } catch {
                    state.errorMessage = error.localizedDescription
                }
                return .none

            case .addButtonTapped:
                keychainUILogger.debug("Received action .addButtonTapped")
                state.destination = .addKeychainItem(
                    AddKeychainItemFeature.State(
                        account: "",
                        secret: ""
                    ))
                return .none

            case .destination(.presented(.addKeychainItem(.delegate(.didSaveKeychainItem)))):
                keychainUILogger.debug("Received action .didSaveKeychainItem, reloading items.")
                return .run { send in
                    await send(.listKeychainItemsButtonTapped)
                }

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
        }
    }
}

extension KeychainUIFeature {
    @Reducer
    enum Destination {
        case addKeychainItem(AddKeychainItemFeature)
    }
}

extension KeychainUIFeature.Destination.State: Equatable {}

struct KeychainUIView: View {
    @Bindable var store: StoreOf<KeychainUIFeature>

    init(store: StoreOf<KeychainUIFeature>) {
        self.store = store
    }

    var body: some View {
        VStack {
            if store.items.isEmpty {
                VStack {
                    Text("No keychain items were found.")
                }
            } else {
                List {
                    ForEach(store.items) { item in
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
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
            }
        }
        .navigationTitle("Issues")
        .toolbar {
            ToolbarItem {
                Button {
                    store.send(.addButtonTapped)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(
            item: $store.scope(state: \.destination?.addKeychainItem, action: \.destination.addKeychainItem)
        ) { addKeychainItemStore in
            NavigationView {
                AddKeychainItemView(store: addKeychainItemStore)
            }
        }
        .onAppear {
            store.send(.listKeychainItemsButtonTapped)
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

#Preview {
    NavigationStack {
        KeychainUIView(store: Store(
            initialState: KeychainUIFeature.State()
        ) { KeychainUIFeature() }
        )
    }
}
