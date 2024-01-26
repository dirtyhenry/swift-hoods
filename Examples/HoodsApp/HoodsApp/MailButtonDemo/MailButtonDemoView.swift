import ComposableArchitecture
import Hoods
import SwiftUI

struct MailButtonDemoView: View {
    let store: StoreOf<MailButtonDemoFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section(header: Text("Mail Content")) {
                    TextField("Recipient", text: viewStore.$recipient)
                        .textInputAutocapitalization(.never)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                    TextField("Subject", text: viewStore.$subject)
                    TextField("Body", text: viewStore.$body)
                }
                MailButtonView(
                    store: store.scope(
                        state: \.mailContent,
                        action: \.mailButton
                    ),
                    label: {
                        Text("Send email")
                    }
                )
            }
        }
        .navigationTitle("Mailer")
    }
}

#Preview {
    MailButtonDemoView(
        store: Store(
            initialState: MailButtonDemoFeature.State()
        ) {
            MailButtonDemoFeature()
        }
    )
}