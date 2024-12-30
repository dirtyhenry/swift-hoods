import ComposableArchitecture
import SwiftUI

@Reducer
struct CounterTabFeature {
    struct State: Equatable {
        var tab1 = CounterFeature.State()
        var tab2 = CounterFeature.State()
    }

    enum Action {
        case tab1(CounterFeature.Action)
        case tab2(CounterFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.tab1, action: \.tab1) {
            CounterFeature()
        }
        Scope(state: \.tab2, action: \.tab2) {
            CounterFeature()
        }
        Reduce { _, _ in
            // Core logic of the app feature
            .none
        }
    }
}

struct CounterTabView: View {
    let store: StoreOf<CounterTabFeature>

    var body: some View {
        TabView {
            Tab("Counter 1", systemImage: "number.square") {
                CounterView(store: store.scope(state: \.tab1, action: \.tab1))
            }

            Tab("Counter 2", systemImage: "number.circle.fill") {
                CounterView(store: store.scope(state: \.tab2, action: \.tab2))
            }
        }
    }
}

#Preview {
    CounterTabView(
        store: Store(initialState: CounterTabFeature.State()) {
            CounterTabFeature()
        }
    )
}
