import Blocks
import ComposableArchitecture
import Foundation
import Hoods
import MessageUI

@Reducer
struct MailButtonDemoFeature {
    struct State: Equatable {
        @BindingState var recipient: String = "foo@bar.tld"
        @BindingState var subject: String = "Hello from the ’hoods"
        @BindingState var body: String = "Look at this awesome TCA mailer"
        var canSendMail: Bool = MFMailComposeViewController.canSendMail()
        var errorDescription: String?

        var mailContent: MailButtonFeature.State {
            get {
                MailButtonFeature.State(
                    mailtoComponents: MailtoComponents(recipient: recipient, subject: subject, body: body),
                    canSendEmail: canSendMail
                )
            }
            set {
                // Unidirectional data flow, do nothing
            }
        }
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case mailButton(MailButtonFeature.Action)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.mailContent, action: \.mailButton) {
            MailButtonFeature()
        }
        Reduce { state, action in
            switch action {
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
