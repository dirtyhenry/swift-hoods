import Blocks
import ComposableArchitecture
import Foundation
import UIKit

@Reducer
struct ImagePickerFeature {
    struct State: Equatable {}

    enum Action {
        // MARK: - UI Interactions

        case cancelButtonTapped
        case usePhotoButtonTapped(UIImage)

        // MARK: - Delegation

        case delegate(Delegate)

        enum Delegate: Equatable {
            case usePhoto(UIImage)
        }
    }

    @Dependency(\.dismiss) var dismiss

    func reduce(into _: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .cancelButtonTapped:
            .run { _ in await dismiss() }

        case let .usePhotoButtonTapped(newPhoto):
            .run { send in
                await send(.delegate(.usePhoto(newPhoto)))
                await dismiss()
            }

        case .delegate:
            .none
        }
    }
}
