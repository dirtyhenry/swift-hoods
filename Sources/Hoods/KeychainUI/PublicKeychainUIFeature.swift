import ComposableArchitecture
import SwiftUI

public struct PublicKeychainUIView: View {
    public init() {}

    public var body: some View {
        KeychainUIView(store: Store(
            initialState: KeychainUIFeature.State()
        ) { KeychainUIFeature() }
        )
    }
}
