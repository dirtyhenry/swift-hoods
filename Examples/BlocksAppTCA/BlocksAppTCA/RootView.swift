import BlocksTCA
import ComposableArchitecture
import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            KeychainUIView(
                store: Store(initialState: KeychainUIFeature.State()) {
                    KeychainUIFeature()
                }
            )
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
