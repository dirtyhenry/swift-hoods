import Blocks
import Foundation
import Yams

struct FrontMatterCMark {
    let frontMatter: [String: Any]
    let cmark: String

    var hasFrontMatter: Bool {
        !frontMatter.isEmpty
    }

    init(frontMatter: [String: Any] = [:], cmark: String = "") {
        self.frontMatter = frontMatter
        self.cmark = cmark
    }
}

class FrontMatterCMarkParser {
    let string: String

    static let frontMatterDelimiter = "---"

    init(data: Data) throws {
        guard let string = String(data: data, encoding: .utf8) else {
            throw SimpleMessageError(message: "Cannot convert data to UTF8.")
        }

        self.string = string
    }

    func parse() throws -> FrontMatterCMark {
        let lines = string.components(separatedBy: .newlines)

        let nonEmptyLines = lines.filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 }
        guard nonEmptyLines.count > 0 else {
            return FrontMatterCMark()
        }

        if let frontMatterIndex = extractFrontMatter(lines: lines) {
            let frontMatterString = lines[1 ..< frontMatterIndex].joined(separator: "\n")
            let cmark = lines[(frontMatterIndex + 1)...].joined(separator: "\n")

            let frontMatter = try Yams.load(yaml: frontMatterString) as! [String: Any]
            return FrontMatterCMark(
                frontMatter: frontMatter,
                cmark: cmark.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        } else {
            return FrontMatterCMark(cmark: string.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }

    func extractFrontMatter(lines: [String]) -> Array.Index? {
        if lines.first!.isFrontMatterDelimiter() {
            return lines.dropFirst().firstIndex { $0.isFrontMatterDelimiter() }
        }

        return nil
    }

    var hasFrontMatter: Bool {
        false
    }
}

extension String {
    func trimmingTrailingCharacters(in _: CharacterSet) -> String {
        guard let lastIndex = (lastIndex { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespacesAndNewlines) }) else {
            return String(self)
        }

        return String(self[...lastIndex])
    }

    func isFrontMatterDelimiter() -> Bool {
        trimmingTrailingCharacters(in: .whitespacesAndNewlines) == FrontMatterCMarkParser.frontMatterDelimiter
    }
}
