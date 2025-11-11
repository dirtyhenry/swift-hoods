import Blocks
import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct AddKeychainItemFeature {
    @ObservableState
    struct State: Equatable {
        var account: String
        var secret: String
        var errorMessage: String?
    }

    enum Action {
        case cancelButtonTapped
        case saveButtonTapped
        case setAccount(String)
        case setSecret(String)

        case delegate(Delegate)
        public enum Delegate: Equatable {
            case didSaveKeychainItem
        }
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.keychainGateway) var keychainGateway

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .run { _ in await dismiss() }

            case .saveButtonTapped:
                keychainUILogger.debug(".saveButtonTapped")
                do {
                    guard let secretData = state.secret.data(using: .utf8) else {
                        throw SimpleMessageError(message: "Could not convert secret to data.")
                    }
                    try keychainGateway.addItem(account: state.account, secret: secretData)

                    return .run { [dismiss] send in
                        await send(.delegate(.didSaveKeychainItem))
                        await dismiss()
                    }
                } catch {
                    state.errorMessage = error.localizedDescription
                    return .none
                }

            case let .setAccount(account):
                keychainUILogger.debug(".setAccount")
                state.account = account
                return .none

            case let .setSecret(secret):
                keychainUILogger.debug(".setSecret")
                state.secret = secret
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

struct AddKeychainItemView: View {
    @Bindable var store: StoreOf<AddKeychainItemFeature>

    var body: some View {
        Form {
            TextField("Account", text: $store.account.sending(\.setAccount))
            SecureField("Secret", text: $store.secret.sending(\.setSecret))
            Button("Save") {
                store.send(.saveButtonTapped)
            }
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
            }
        }
    }
}

#Preview {
    AddKeychainItemView(store: Store(
        initialState: AddKeychainItemFeature.State(account: "", secret: "")
    ) {
        AddKeychainItemFeature()
    }
    )
}
