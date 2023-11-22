import Blocks
import Foundation
import Yams

public struct FrontMatterCMark<T: Codable> {
    public let frontMatter: T?
    public let cmark: String

    public init(frontMatter: T?, cmark: String) {
        self.frontMatter = frontMatter
        self.cmark = cmark
    }
}

enum FrontMatterCMarkUtils {
    public static let frontMatterDelimiter = "---"
}

public class FrontMatterCMarkDecoder {
    public init() {}

    public func decode<T>(_: T.Type, from data: Data) throws -> FrontMatterCMark<T> where T: Decodable {
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
            let frontMatter = try decoder.decode(T.self, from: frontMatterString)

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

public class FrontMatterCMarkEncoder {
    public init() {}

    public func encode(_ value: FrontMatterCMark<some Any>) throws -> Data {
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

    private func encodeFrontMatter(_ value: FrontMatterCMark<some Any>) throws -> String {
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
        guard let lastIndex = (lastIndex { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespacesAndNewlines) }) else {
            return String(self)
        }

        return String(self[...lastIndex])
    }

    func isFrontMatterDelimiter() -> Bool {
        trimmingTrailingCharacters(in: .whitespacesAndNewlines) == FrontMatterCMarkUtils.frontMatterDelimiter
    }
}
