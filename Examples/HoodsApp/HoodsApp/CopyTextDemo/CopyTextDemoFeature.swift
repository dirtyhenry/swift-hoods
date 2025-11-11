import ComposableArchitecture
import Foundation
import Hoods
import SwiftUI

@Reducer
struct CopyTextDemoFeature {
    @ObservableState
    struct State: Equatable {
        var text: String = "Please edit me."
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

struct CopyTextDemoView: View {
    @Bindable var store: StoreOf<CopyTextDemoFeature>

    var body: some View {
        VStack {
            TextEditor(text: $store.text)
            Button("Copy", systemImage: "doc.on.doc") {
                store.send(.copyButtonTapped)
            }
        }
        .padding()
        .navigationTitle("CopyText Demo")
    }
}

#Preview {
    CopyTextDemoView(
        store: Store(
            initialState: CopyTextDemoFeature.State()
        ) {
            CopyTextDemoFeature()
        }
    )
}
