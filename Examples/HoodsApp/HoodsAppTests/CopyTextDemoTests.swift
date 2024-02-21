import ComposableArchitecture
@testable import HoodsApp
import HoodsTestsTools
import SnapshotTesting
import XCTest

@MainActor
final class CopyTextDemoTests: XCTestCase {
    func testCopyTextDemo() async throws {
        let copyText = TestDependenciesFactory.CopyText()

        let store = TestStore(initialState: CopyTextDemoFeature.State()) {
            CopyTextDemoFeature()
        } withDependencies: {
            $0.copyText = copyText.effect
        }

        await store.send(.set(\.$text, "Hello World")) {
            $0.text = "Hello World"
        }

        await store.send(.copyButtonTapped)

        XCTAssertEqual(copyText.spy.value.count, 1)
        XCTAssertEqual(try XCTUnwrap(copyText.spy.value.last), "Hello World")
    }
}
