import Blocks
import ComposableArchitecture
import Foundation
import Hoods
import MessageUI

@Reducer
struct MailButtonDemoFeature {
    struct State: Equatable {
        @BindingState var subject: String
        @BindingState var body: String
        var errorDescription: String?

        var mailContent: MailButtonFeature.State

        init(recipient: String = "foo@bar.tld",
             subject: String = "Hello from the ’hoods",
             body: String = "Look at this awesome TCA mailer") {
            self.subject = subject
            self.body = body

            mailContent = .init(
                mailtoComponents: MailtoComponents(
                    recipient: recipient,
                    subject: subject,
                    body: body
                ),
                canSendEmail: MFMailComposeViewController.canSendMail()
            )
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)

        case recipientChanged(String)

        case mailButton(MailButtonFeature.Action)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.mailContent, action: \.mailButton) {
            MailButtonFeature()
        }
        Reduce { state, action in
            switch action {
            case .binding:
                // Keep fields up to date
                state.mailContent.mailtoComponents.subject = state.subject
                state.mailContent.mailtoComponents.body = state.body
                return .none
            case let .recipientChanged(recipient):
                state.mailContent.mailtoComponents.recipient = recipient
                return .none
            case .mailButton(.buttonTapped):
                state.errorDescription = nil
                return .none
            case let .mailButton(.delegate(.shouldPresentError(error))):
                state.errorDescription = "\(error)"
                return .none
            default:
                return .none
            }
        }
    }
}
