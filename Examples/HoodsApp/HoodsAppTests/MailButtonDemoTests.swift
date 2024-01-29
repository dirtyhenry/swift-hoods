import ComposableArchitecture
@testable import HoodsApp
import HoodsTestsTools
import SnapshotTesting
import XCTest

@MainActor
final class MailButtonDemoTests: XCTestCase {
    func testMailButtonDemo() async throws {
        let openURL = TestDependenciesFactory.OpenURL()

        let store = TestStore(initialState: MailButtonDemoFeature.State()) {
            MailButtonDemoFeature()
        } withDependencies: {
            $0.openURL = openURL.effect
        }
        await store.send(.recipientChanged("john.doe@example.com")) {
            $0.mailContent.mailtoComponents.recipient = "john.doe@example.com"
        }
        await store.send(.set(\.$subject, "Hey Joe")) {
            $0.subject = "Hey Joe"
            $0.mailContent.mailtoComponents.subject = "Hey Joe"
        }
        await store.send(.set(\.$body, "Have you heard of Jimi Hendrix?")) {
            $0.body = "Have you heard of Jimi Hendrix?"
            $0.mailContent.mailtoComponents.body = "Have you heard of Jimi Hendrix?"
        }

        await store.send(.mailButton(.buttonTapped))
        XCTAssertEqual(
            openURL.spy.value,
            [URL(string: "mailto:john.doe@example.com?subject=Hey%20Joe&body=Have%20you%20heard%20of%20Jimi%20Hendrix?")]
        )
    }
}
