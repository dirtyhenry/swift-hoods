import Foundation
import Hoods
import XCTest

class InputableValueTests: XCTestCase {
    func testInputByArgument() throws {
        XCTAssertEqual(try InputableValue<String>.init(argument: "Test").get(), "Test")
        XCTAssertEqual(try InputableValue<Int>.init(argument: "123").get(), 123)
    }
}
