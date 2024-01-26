import Blocks
import ComposableArchitecture
import Foundation

@Reducer
public struct MailButtonFeature {
    public struct State: Equatable {
        @PresentationState var destination: Destination.State?
        var mailtoComponents: MailtoComponents
        var canSendEmail: Bool

        public init(mailtoComponents: MailtoComponents, canSendEmail: Bool) {
            self.mailtoComponents = mailtoComponents
            self.canSendEmail = canSendEmail
        }
    }

    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case delegate(Delegate)
        case buttonTapped

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

                    return .run { send in
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

// TODO: Move to Blocks maybe?
public extension MailtoComponents {
    init(recipient: String, subject: String, body: String) {
        self.init()
        self.recipient = recipient
        self.subject = subject
        self.body = body
    }
}
