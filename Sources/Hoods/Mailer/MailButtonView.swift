#if canImport(MessageUI)
import Blocks
import ComposableArchitecture
import SwiftUI

public struct MailButtonView<Label: View>: View {
    let store: StoreOf<MailButtonFeature>
    let label: Label

    public init(
        store: StoreOf<MailButtonFeature>,
        @ViewBuilder label: () -> Label
    ) {
        self.store = store
        self.label = label()
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Button {
                viewStore.send(.buttonTapped)
            } label: {
                label
            }
            .fullScreenCover(
                store: store.scope(
                    state: \.$destination.mailCompose,
                    action: \.destination.mailCompose
                )
            ) { mailComposeStore in
                MailerView(store: mailComposeStore)
                    .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    MailButtonView(
        store: Store(
            initialState: MailButtonFeature.State(
                mailtoComponents: MailtoComponents(
                    recipient: "foo@bar.tld",
                    subject: "Hello John Doe",
                    body: "How are you?"
                ),
                canSendEmail: false
            )
        ) {
            MailButtonFeature()
        },
        label: {
            Text("Send")
        }
    )
}
#endif
