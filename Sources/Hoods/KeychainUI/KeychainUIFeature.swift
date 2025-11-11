import ComposableArchitecture
import Foundation
import os

let keychainUILogger = Logger(subsystem: "swift-hoods", category: "KeychainUI")

extension KeychainItem: Identifiable {
    public var id: String {
        account
    }
}

@Reducer
public struct KeychainUIFeature {
    public struct State: Equatable {
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

    public init() {}

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
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
    }
}

public extension KeychainUIFeature {
    @Reducer
    struct Destination {
        public enum State: Equatable {
            case addKeychainItem(AddKeychainItemFeature.State)
        }

        public enum Action {
            case addKeychainItem(AddKeychainItemFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(
                state: \.addKeychainItem,
                action: \.addKeychainItem
            ) {
                AddKeychainItemFeature()
            }
        }
    }
}
