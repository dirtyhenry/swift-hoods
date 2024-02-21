import ComposableArchitecture
import Foundation
import Hoods

/// Factory for creating dependencies used in testing.
public enum TestDependenciesFactory {
    /// Factory for creating a test instance of `OpenURL`.
    public class OpenURL {
        /// Spy to observe invocations of the `OpenURL` effect.
        public let spy: LockIsolated<[URL]>

        /// Effect that simulates opening a URL.
        public let effect: OpenURLEffect

        /// Initializes a new instance of `OpenURL`.
        public init() {
            let _spy = LockIsolated<[URL]>.init([])
            effect = OpenURLEffect { url in
                _spy.withValue { $0.append(url) }
                return true
            }
            spy = _spy
        }
    }

    /// Factory for creating a test instance of `CopyText`.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Arrange
    /// let copyText = TestDependenciesFactory.CopyText()
    ///
    /// let store = TestStore(initialState: ….State()) {
    ///     …Feature()
    /// } withDependencies: {
    ///     $0.copyText = copyText.effect
    /// }
    ///
    /// // Act
    /// …
    ///
    /// // Assert
    /// XCTAssertEqual(copyText.spy.value.last.count, 1)
    /// let copiedText = try XCTUnwrap(copyText.spy.value.last)
    /// XCTAssertEqual(copiedText, "foo")
    /// ```
    public class CopyText {
        /// Spy to observe invocations of the `CopyText` effect.
        public let spy: LockIsolated<[String]>

        /// Effect that simulates copying text.
        public let effect: CopyTextEffect

        /// Initializes a new instance of `CopyText`.
        public init() {
            let _spy = LockIsolated<[String]>.init([])
            effect = CopyTextEffect { text in
                _spy.withValue { $0.append(text) }
                return true
            }
            spy = _spy
        }
    }
}
