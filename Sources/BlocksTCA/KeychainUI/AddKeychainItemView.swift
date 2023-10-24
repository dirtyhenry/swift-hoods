import Blocks
import ComposableArchitecture
import SwiftUI

struct AddKeychainItemView: View {
    let store: StoreOf<AddKeychainItemFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                TextField("Account", text: viewStore.binding(
                    get: \.account,
                    send: { .setAccount($0) }
                ))
                SecureField("Secret", text: viewStore.binding(
                    get: \.secret,
                    send: { .setSecret($0) }
                ))
                Button("Save") {
                    viewStore.send(.saveButtonTapped)
                }
                if let errorMessage = viewStore.errorMessage {
                    Text(errorMessage)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button("Cancel") {
                        viewStore.send(.cancelButtonTapped)
                    }
                }
            }
        }
    }
}

struct AddKeychainItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddKeychainItemView(store: Store(
            initialState: AddKeychainItemFeature.State(account: "", secret: "")
        ) { AddKeychainItemFeature() }
        )
    }
}
