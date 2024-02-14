#if os(macOS)
import AppKit
#endif
#if os(iOS)
import UIKit
import UniformTypeIdentifiers
#endif
import Dependencies

extension DependencyValues {
    public var copyText: CopyTextEffect {
        get { self[CopyTextKey.self] }
        set { self[CopyTextKey.self] = newValue }
    }

    private enum CopyTextKey: DependencyKey {
        static let liveValue = CopyTextEffect { text in
            #if os(macOS)
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            return pasteboard.setString(text, forType: .string)
            #endif

            #if os(iOS)
            let pasteboard = UIPasteboard.general
            pasteboard.setValue(text, forPasteboardType: UTType.utf8PlainText.identifier)
            return true
            #endif
        }
    }
}

public struct CopyTextEffect: Sendable {
    private let handler: @Sendable (String) async -> Bool

    public init(handler: @escaping @Sendable (String) async -> Bool) {
        self.handler = handler
    }

    @discardableResult
    public func callAsFunction(_ text: String) async -> Bool {
        await handler(text)
    }
}
