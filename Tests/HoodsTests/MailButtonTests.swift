#if canImport(MessageUI)
import Blocks
import ComposableArchitecture
@testable import Hoods
import HoodsTestsTools
import XCTest

@MainActor
final class MailButtonTests: XCTestCase {
    let mailtoComponents = MailtoComponents(recipient: "foo@bar.tld", subject: "Subject", body: "Body")

    func testWhenCanSendMail() async throws {
        // Arrange a state that can send emails
        let openURL = TestDependenciesFactory.OpenURL()
        let initialState = MailButtonFeature.State(
            mailtoComponents: mailtoComponents,
            canSendEmail: true
        )
        let store = TestStore(initialState: initialState) {
            MailButtonFeature()
        } withDependencies: {
            $0.openURL = openURL.effect
        }

        // Act: tap the send button
        await store.send(.buttonTapped) {
            // Assert: an in-app composer was presented
            $0.destination = .mailCompose(MailerFeature.State(
                mailtoComponents: MailtoComponents(
                    recipient: "foo@bar.tld",
                    subject: "Subject",
                    body: "Body"
                )
            ))
        }
    }

    func testWhenCanNotSendMail() async throws {
        // Arrange a state that can not send emails
        let openURL = TestDependenciesFactory.OpenURL()
        let initialState = MailButtonFeature.State(
            mailtoComponents: mailtoComponents,
            canSendEmail: false
        )
        let store = TestStore(initialState: initialState) {
            MailButtonFeature()
        } withDependencies: {
            $0.openURL = openURL.effect
        }

        // Act: tap the send button
        await store.send(.buttonTapped)

        // Assert: no state change
        // … but an open URL effect
        XCTAssertEqual(openURL.spy.value, [URL(string: "mailto:foo@bar.tld?subject=Subject&body=Body")])
    }
}
#endif
