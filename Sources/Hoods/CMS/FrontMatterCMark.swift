import Blocks
import Foundation
import Yams

/// Represents a combination of front matter (metadata) and CommonMark text.
///
/// To learn more about front matters, please read the post I wrote about it on my technical blog:
/// [*My Definitive Front Matter*][1].
///
/// CommonMark is defined as: “a strongly defined, highly compatible specification of Markdown”
///
/// You can read more about it on [commonmark.org][2].
///
/// [1]: https://bootstragram.com/blog/my-definitive-front-matter/
/// [2]: https://commonmark.org/
public struct FrontMatterCMark<FrontMatter: Codable> {
    /// A front matter of a generic codable type.
    public let frontMatter: FrontMatter?

    /// The CommonMark text associated with the front matter.
    public let cmark: String

    /// Initializes a new `FrontMatterCMark` instance.
    ///
    /// - Parameters:
    ///   - frontMatter: The decoded front matter of type `FrontMatter`.
    ///   - cmark: The CommonMark text associated with the front matter.
    public init(frontMatter: FrontMatter?, cmark: String) {
        self.frontMatter = frontMatter
        self.cmark = cmark
    }
}

enum FrontMatterCMarkUtils {
    static let frontMatterDelimiter = "---"
}

/// A decoder for extracting front matter and CommonMark text from a given data.
public class FrontMatterCMarkDecoder {
    /// Initializes a new `FrontMatterCMarkDecoder` instance.
    public init() {}

    /// Decodes front matter and CommonMark text from the provided data.
    ///
    /// - Parameters:
    ///   - type: The type to decode the front matter into.
    ///   - data: The data containing front matter and CommonMark text.
    /// - Returns: A `FrontMatterCMark` instance with the decoded front matter and CommonMark text.
    /// - Throws: A decoding error if the front matter cannot be decoded.
    public func decode<FrontMatter>(
        _: FrontMatter.Type,
        from data: Data
    ) throws -> FrontMatterCMark<FrontMatter> where FrontMatter: Decodable {
        guard let dataAsString = String(data: data, encoding: .utf8) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Could not convert data to UTF8 string."))
        }

        let lines = dataAsString.components(separatedBy: .newlines)

        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !nonEmptyLines.isEmpty else {
            return FrontMatterCMark(frontMatter: nil, cmark: "")
        }

        if let frontMatterIndex = extractFrontMatter(lines: lines) {
            let frontMatterString = lines[1 ..< frontMatterIndex].joined(separator: "\n")
            let cmark = lines[(frontMatterIndex + 1)...].joined(separator: "\n")

            let decoder = YAMLDecoder()
            let frontMatter = try decoder.decode(FrontMatter.self, from: frontMatterString)

            return FrontMatterCMark(
                frontMatter: frontMatter,
                cmark: cmark.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        } else {
            return FrontMatterCMark(
                frontMatter: nil,
                cmark: dataAsString.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
    }

    private func extractFrontMatter(lines: [String]) -> Array.Index? {
        if lines.first!.isFrontMatterDelimiter() {
            return lines.dropFirst().firstIndex { $0.isFrontMatterDelimiter() }
        }

        return nil
    }
}

/// A encoder for encoding `FrontMatterCMark` instances.
public class FrontMatterCMarkEncoder {
    /// Initializes a new `FrontMatterCMarkEncoder` instance.
    public init() {}

    /// Encodes the given `FrontMatterCMark` instance into data.
    ///
    /// - Parameter value: The `FrontMatterCMark` instance to encode.
    /// - Returns: The encoded data.
    /// - Throws: An encoding error if the front matter cannot be encoded.
    public func encode(
        _ value: FrontMatterCMark<some Encodable>
    ) throws -> Data {
        let frontMatterString = try encodeFrontMatter(value)
        let fullString = [
            frontMatterString,
            "",
            value.cmark.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        ].joined(separator: "\n")
        return Data(fullString.utf8)
    }

    private func encodeFrontMatter(
        _ value: FrontMatterCMark<some Encodable>
    ) throws -> String {
        guard let frontMatter = value.frontMatter else {
            return ""
        }

        let yamlEncoder = YAMLEncoder()
        yamlEncoder.options = .init(indent: 2, width: 80)
        let yaml = try yamlEncoder.encode(frontMatter)
        return [
            FrontMatterCMarkUtils.frontMatterDelimiter,
            yaml.trimmingCharacters(in: .whitespacesAndNewlines),
            FrontMatterCMarkUtils.frontMatterDelimiter
        ].joined(separator: "\n")
    }
}

public extension String {
    func trimmingTrailingCharacters(in _: CharacterSet) -> String {
        guard let lastIndex = (lastIndex { !CharacterSet(charactersIn: String($0))
                .isSubset(of: .whitespacesAndNewlines)
        }) else {
            return String(self)
        }

        return String(self[...lastIndex])
    }

    func isFrontMatterDelimiter() -> Bool {
        trimmingTrailingCharacters(in: .whitespacesAndNewlines) == FrontMatterCMarkUtils.frontMatterDelimiter
    }
}
