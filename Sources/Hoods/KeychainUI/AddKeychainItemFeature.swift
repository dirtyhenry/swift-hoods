import Blocks
import ComposableArchitecture
import Foundation

public struct AddKeychainItemFeature: Reducer {
    public struct State {
        var account: String
        var secret: String
        var errorMessage: String?
    }

    public enum Action {
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

    public var body: some Reducer<State, Action> {
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

                    return .run { send in
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

extension AddKeychainItemFeature.State: Equatable {}
extension AddKeychainItemFeature.Action: Equatable {}
