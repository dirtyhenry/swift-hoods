import Blocks
import SnapshotTesting
import Foundation

/// A transport wrapper that captures snapshots of URL requests and responses for testing purposes.
/// 
/// `SnapshottingTransport` intercepts network requests and responses, using the SnapshotTesting
/// framework to assert snapshots of the request, returned data, and HTTP response. This is useful 
/// for verifying network interactions in tests by capturing and comparing snapshots.
///
public struct SnapshottingTransport: Transport {
    /// The file where the snapshot assertions are recorded.
    public let file: StaticString
    
    /// The underlying transport being wrapped.
    public let wrapped: Transport
    
    /// The name of the test function to associate snapshots with.
    public let testName: String

    /// Creates a new instance wrapping the given transport.
    ///
    /// - Parameters:
    ///   - wrapping: The transport to wrap and forward requests to.
    ///   - file: The file used for snapshot assertions. Defaults to the calling file.
    ///   - testName: The test function name used for snapshot assertions. Defaults to the calling function.
    public init(wrapping: Transport, file: StaticString = #filePath, testName: String = #function) {
        wrapped = wrapping
        self.file = file
        self.testName = testName
    }

    /// Sends a URL request using the wrapped transport, capturing snapshots of the request,
    /// response data, and HTTP response for test verification.
    ///
    /// - Parameters:
    ///   - urlRequest: The URL request to send.
    ///   - delegate: An optional URLSessionTaskDelegate to receive task-level events.
    /// - Returns: A tuple containing the response data and HTTP URL response.
    /// - Throws: Rethrows any error thrown by the wrapped transport's send method.
    public func send(urlRequest: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, HTTPURLResponse) {
        withSnapshotTesting {
            assertSnapshot(of: urlRequest, as: .raw(pretty: true), file: file, testName: testName)
        }

        let (data, httpResponse) = try await wrapped.send(urlRequest: urlRequest, delegate: delegate)

        withSnapshotTesting {
            assertSnapshot(of: data, as: .data, file: file, testName: testName)
            assertSnapshot(of: httpResponse, as: .dump, file: file, testName: testName)
        }

        return (data, httpResponse)
    }
}
