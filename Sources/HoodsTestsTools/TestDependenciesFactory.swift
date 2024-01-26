import ComposableArchitecture
import Foundation

public enum TestDependenciesFactory {
    public class OpenURL {
        public let spy: LockIsolated<[URL]>
        public let effect: OpenURLEffect

        public init() {
            let _spy = LockIsolated<[URL]>.init([])
            effect = OpenURLEffect { url in
                _spy.withValue { $0.append(url) }
                return true
            }
            spy = _spy
        }
    }
}
