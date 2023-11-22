import Foundation
import Hoods
import XCTest

class FrontMatterCMarkTests: XCTestCase {
    struct DemoFrontMatter: Codable {
        let layout: String
        let id: String
        let title: String
        let authors: [String]
        let excerpt: String
        let category: String
        let tags: [String]
    }

    func testBasicDecodingAndReEncoding() throws {
        guard let sampleURL = Bundle.module.url(forResource: "sample-front-matter", withExtension: "md") else {
            fatalError("Couldnot find URL of a test resource.")
        }

        let originalData = try Data(contentsOf: sampleURL)

        let sut = try FrontMatterCMarkDecoder().decode(DemoFrontMatter.self, from: originalData)
        let frontMatter = try XCTUnwrap(sut.frontMatter)
        XCTAssertEqual(frontMatter.layout, "post")
        XCTAssertEqual(frontMatter.id, "efee651d-ae92-4dfb-9009-16141b4e3dcb")
        XCTAssertEqual(frontMatter.title, "Dummy Title")
        XCTAssertEqual(frontMatter.authors, ["This Author"])
        XCTAssertEqual(frontMatter.excerpt, "Lorem ipsum dolor' sit \"amet\": consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Semper eget duis at tellus. Magnis dis parturient montes nascetur ridiculus mus mauris vitae ultricies. In eu mi bibendum neque egestas. Tortor consequat id porta nibh venenatis. Nibh tortor id aliquet lectus proin nibh nisl.")
        XCTAssertEqual(frontMatter.category, "A metadata category")
        XCTAssertEqual(frontMatter.tags, ["A metadata tag"])

        XCTAssertEqual(
            sut.cmark,
            """
            Some markdown.

            - List item 1
            - List item 2

            ## A header of level 2

            Some more text.
            """.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        let dataFromSut = try FrontMatterCMarkEncoder().encode(sut)
        let stringFromDataSut = try XCTUnwrap(String(data: dataFromSut, encoding: .utf8))

        XCTAssertEqual(
            stringFromDataSut,
            """
            ---
            layout: post
            id: efee651d-ae92-4dfb-9009-16141b4e3dcb
            title: Dummy Title
            authors:
            - This Author
            excerpt: 'Lorem ipsum dolor'' sit "amet": consectetur adipiscing elit, sed do eiusmod
              tempor incididunt ut labore et dolore magna aliqua. Semper eget duis at tellus.
              Magnis dis parturient montes nascetur ridiculus mus mauris vitae ultricies. In eu
              mi bibendum neque egestas. Tortor consequat id porta nibh venenatis. Nibh tortor
              id aliquet lectus proin nibh nisl.'
            category: A metadata category
            tags:
            - A metadata tag
            ---

            Some markdown.

            - List item 1
            - List item 2

            ## A header of level 2

            Some more text.
            """
        )
    }

    func testTrimmingTrailingCharactersExtension() throws {
        XCTAssertEqual("   Bonjour".trimmingTrailingCharacters(in: .whitespacesAndNewlines), "   Bonjour")
        XCTAssertEqual("   Bonjour".trimmingTrailingCharacters(in: .whitespacesAndNewlines), "   Bonjour")
        XCTAssertEqual("   Bonjour   ".trimmingTrailingCharacters(in: .whitespacesAndNewlines), "   Bonjour")
        XCTAssertEqual("Bonjour   ".trimmingTrailingCharacters(in: .whitespacesAndNewlines), "Bonjour")
    }
}
