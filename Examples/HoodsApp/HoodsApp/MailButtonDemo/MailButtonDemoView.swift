import ComposableArchitecture
import Hoods
import SwiftUI

struct MailButtonDemoView: View {
    let store: StoreOf<MailButtonDemoFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section(header: Text("Mail Content")) {
                    TextField("Recipient", text: viewStore.binding(
                        get: { $0.mailContent.mailtoComponents.recipient ?? "" },
                        send: { .recipientChanged($0) }
                    ))
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    TextField("Subject", text: viewStore.$subject)
                    TextField("Body", text: viewStore.$body)
                }
                VStack {
                    MailButtonView(
                        store: store.scope(
                            state: \.mailContent,
                            action: \.mailButton
                        ),
                        label: {
                            Text("Send email")
                        }
                    )

                    if let errorDescription = viewStore.errorDescription {
                        Text(errorDescription)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
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
