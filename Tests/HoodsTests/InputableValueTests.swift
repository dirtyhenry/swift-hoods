import Foundation
import Hoods
import XCTest

class InputableValueTests: XCTestCase {
    func testInputByArgument() throws {
        XCTAssertEqual(try InputableValue<String>(argument: "Test").get(), "Test")
        XCTAssertEqual(try InputableValue<Int>(argument: "123").get(), 123)
        XCTAssertEqual(try InputableValue<Bool>(argument: "true").get(), true)
    }
}
