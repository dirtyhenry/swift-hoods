import ComposableArchitecture
import SwiftUI

struct CopyTextDemoView: View {
    let store: StoreOf<CopyTextDemoFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                TextEditor(text: viewStore.$text)
                Button("Copy", systemImage: "doc.on.doc") {
                    viewStore.send(.copyButtonTapped)
                }
            }
            .padding()
            .navigationTitle("CopyText Demo")
        }
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
