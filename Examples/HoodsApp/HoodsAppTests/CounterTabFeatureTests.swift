import ComposableArchitecture
import Testing

@testable import HoodsApp

@MainActor
struct CounterTabFeatureTests {
    @Test
    func incrementInFirstTab() async {
        let store = TestStore(initialState: CounterTabFeature.State()) {
            CounterTabFeature()
        }

        await store.send(\.tab1.incrementButtonTapped) {
            $0.tab1.count = 1
        }
    }
}
