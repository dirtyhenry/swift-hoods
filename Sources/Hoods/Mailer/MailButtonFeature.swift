#if canImport(MessageUI)
import Blocks
import ComposableArchitecture
import Foundation

/// A SwiftUI Reducer representing a mail button feature.
///
///
@Reducer
public struct MailButtonFeature {
    // MARK: - State

    public struct State: Equatable {
        /// The state of the destination screen, if applicable.
        @PresentationState var destination: Destination.State?

        /// The components used to the mail to be sent.
        public var mailtoComponents: MailtoComponents

        /// A boolean indicating whether the device can send *in-app* emails.
        ///
        /// Typically, it should be set to the value of `MFMailComposeViewController.canSendMail()`
        public var canSendEmail: Bool

        /// Initializes the state with the given parameters.
        ///
        /// - Parameters:
        ///   - mailtoComponents: The components used to construct a 'mailto' URL.
        ///   - canSendEmail: A boolean indicating whether the device can send emails.
        public init(mailtoComponents: MailtoComponents, canSendEmail: Bool) {
            self.mailtoComponents = mailtoComponents
            self.canSendEmail = canSendEmail
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: - Main Actions

        /// Action triggered when the mail button is tapped.
        case buttonTapped

        // MARK: - Navigation-related actions

        /// Actions related to the destination screen.
        case destination(PresentationAction<Destination.Action>)

        /// Delegate actions for handling specific scenarios.
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case shouldPresentError(MailButtonError)
        }
    }

    @Dependency(\.openURL) var openURL

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .buttonTapped:
                if state.canSendEmail {
                    state.destination = .mailCompose(MailerFeature.State(mailtoComponents: state.mailtoComponents))
                    return .none
                } else {
                    guard let mailtoURL = state.mailtoComponents.url else {
                        return .send(.delegate(.shouldPresentError(.noURLFromMailtoComponents)))
                    }

                    return .run { [openURL] send in
                        let isSuccess = await openURL(mailtoURL)
                        if !isSuccess {
                            await send(.delegate(.shouldPresentError(.openURLFailed)))
                        }
                    }
                }

            case .destination, .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
    }
}

public extension MailButtonFeature {
    @Reducer
    struct Destination {
        public enum State: Equatable {
            case mailCompose(MailerFeature.State)
        }

        public enum Action {
            case mailCompose(MailerFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.mailCompose, action: \.mailCompose) {
                MailerFeature()
            }
        }
    }
}

public enum MailButtonError {
    case noURLFromMailtoComponents
    case openURLFailed
}
#endif
