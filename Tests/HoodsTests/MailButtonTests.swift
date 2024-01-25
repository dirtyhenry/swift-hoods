import ComposableArchitecture
@testable import Hoods

@MainActor
final class MailButtonTests: XCTestCase {
    let mailContent = MailContent(recipient: "foo@bar.tld", subject: "Subject", body: "Body")

    func testWhenCanSendMail() async throws {
        // Arrange a state that can send emails
        let openURLSpy: LockIsolated<[URL]> = .init([])
        let initialState = MailButtonFeature.State(
            mailContent: mailContent,
            canSendEmail: true
        )
        let store = TestStore(initialState: initialState) {
            MailButtonFeature()
        } withDependencies: {
            $0.openURL = OpenURLEffect { url in
                openURLSpy.withValue { $0.append(url) }
                return true
            }
        }

        // Act: tap the send button
        await store.send(.buttonTapped) {
            // Assert: an in-app composer was presented
            $0.destination = .mailCompose(MailerFeature.State(
                mailContent: MailContent(
                    recipient: "foo@bar.tld",
                    subject: "Subject",
                    body: "Body"
                )
            ))
        }
    }

    func testWhenCanNotSendMail() async throws {
        // Arrange a state that can not send emails
        let openURLSpy: LockIsolated<[URL]> = .init([])
        let initialState = MailButtonFeature.State(
            mailContent: mailContent,
            canSendEmail: false
        )
        let store = TestStore(initialState: initialState) {
            MailButtonFeature()
        } withDependencies: {
            $0.openURL = OpenURLEffect { url in
                openURLSpy.withValue { $0.append(url) }
                return true
            }
        }

        // Act: tap the send button
        await store.send(.buttonTapped)

        // Assert: no state change
        // … but an open URL effect
        XCTAssertEqual(openURLSpy.value, [URL(string: "mailto:foo@bar.tld?subject=Subject&body=Body")])
    }
}
