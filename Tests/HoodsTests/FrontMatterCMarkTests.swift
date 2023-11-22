import Foundation
@testable import Hoods
import XCTest

class FrontMatterCMarkTests: XCTestCase {
    func testBasicParsing() throws {
        guard let sampleURL = Bundle.module.url(forResource: "sample-front-matter", withExtension: "md") else {
            fatalError("Couldnot find URL of a test resource.")
        }

        let data = try Data(contentsOf: sampleURL)

        let parser = try FrontMatterCMarkParser(data: data)
        let sut = try parser.parse()
        XCTAssertTrue(sut.hasFrontMatter)
        XCTAssertEqual(sut.frontMatter["layout"] as! String, "post")
        XCTAssertEqual(sut.frontMatter["id"] as! String, "efee651d-ae92-4dfb-9009-16141b4e3dcb")
        XCTAssertEqual(sut.frontMatter["title"] as! String, "Dummy Title")
        XCTAssertEqual(sut.frontMatter["authors"] as! [String], ["This Author"])
        XCTAssertEqual(sut.frontMatter["excerpt"] as! String, "An excerpt")
        XCTAssertEqual(sut.frontMatter["category"] as! String, "A metadata category")
        XCTAssertEqual(sut.frontMatter["tags"] as! [String], ["A metadata tag"])

        XCTAssertEqual(
            sut.cmark,
            """
            Some markdown.

            * List item 1
            * List item 2

            ## A header of level 2

            Some more text.
            """.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    func testTrimmingTrailingCharactersExtension() throws {
        XCTAssertEqual("   Bonjour".trimmingTrailingCharacters(in: .whitespacesAndNewlines), "   Bonjour")
        XCTAssertEqual("   Bonjour".trimmingTrailingCharacters(in: .whitespacesAndNewlines), "   Bonjour")
        XCTAssertEqual("   Bonjour   ".trimmingTrailingCharacters(in: .whitespacesAndNewlines), "   Bonjour")
        XCTAssertEqual("Bonjour   ".trimmingTrailingCharacters(in: .whitespacesAndNewlines), "Bonjour")
    }
}
