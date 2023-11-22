import ComposableArchitecture
import Foundation
import os

let keychainUILogger = Logger(subsystem: "swift-blocks-tca", category: "KeychainUI")

extension KeychainItem: Identifiable {
    public var id: String {
        account
    }
}

public struct KeychainUIFeature: Reducer {
    public init() {}

    public struct State {
        @PresentationState var destination: Destination.State?

        var items: [KeychainItem]
        var errorMessage: String?

        public init(items: [KeychainItem] = []) {
            self.items = items
        }
    }

    public enum Action {
        case listKeychainItemsButtonTapped
        case addButtonTapped

        case destination(PresentationAction<Destination.Action>)
    }

    @Dependency(\.keychainGateway) var keychainGateway

    public var body: some Reducer<State, Action> {
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
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

extension KeychainUIFeature.State: Equatable {}
extension KeychainUIFeature.Action: Equatable {}

public extension KeychainUIFeature {
    struct Destination: Reducer {
        public enum State: Equatable {
            case addKeychainItem(AddKeychainItemFeature.State)
        }

        public enum Action: Equatable {
            case addKeychainItem(AddKeychainItemFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(
                state: /State.addKeychainItem,
                action: /Action.addKeychainItem
            ) {
                AddKeychainItemFeature()
            }
        }
    }
}
