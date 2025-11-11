import Blocks
import SnapshotTesting
import Testing
import Foundation
import HoodsTestsTools

@Suite("SnapshottingTransport")
struct SnapshottingTransportTests {
    @Test("wraps MockTransport and snapshots request/response")
    func testSnapshotsMockTransport() async throws {
        // Arrange: Create a MockTransport with known data
        let mockData = Data("Hello, snapshot!".utf8)
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "text/plain"]
        )!
        let mockTransport = MockTransport(data: mockData, response: mockResponse)
        let snapshottingTransport = SnapshottingTransport(wrapping: mockTransport)

        let request = URLRequest(url: URL(string: "https://example.com/foo")!)

        // Act: Send the request using the snapshotting transport
        let (data, response) = try await snapshottingTransport.send(urlRequest: request, delegate: nil)

        // Assert: Check returned data and response match the mock
        #expect(data == mockData, "Returned data should match mock data")
        #expect(response.statusCode == 200, "Status code should be 200")
        #expect(response.url == URL(string: "https://example.com"), "Response URL should match")
        #expect(response.value(forHTTPHeaderField: "Content-Type") == "text/plain")
    }
}
