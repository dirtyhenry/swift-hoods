import ComposableArchitecture
import Foundation
import Hoods

@Reducer
struct CopyTextDemoFeature {
    struct State: Equatable {
        @BindingState var text: String = "Please edit me."
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case copyButtonTapped
    }

    @Dependency(\.copyText) var copyText

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .copyButtonTapped:
                .run { [text = state.text] _ in
                    await copyText(text)
                }

            case .binding:
                .none
            }
        }
    }
}
