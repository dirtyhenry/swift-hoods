import Blocks
import Dependencies
import Foundation
import JWTKit

extension DependencyValues {
    public var jwtFactory: JWTFactory {
        get { self[JWTFactoryKey.self] }
        set { self[JWTFactoryKey.self] = newValue }
    }

    private enum JWTFactoryKey: DependencyKey {
        static let liveValue: JWTFactory = UnimplementedJWTFactory()

        #if DEBUG
        static let previewValue: JWTFactory = MockJWTFactory()
        static let testValue: JWTFactory = MockJWTFactory()
        #endif
    }
}

public protocol JWTFactory: Sendable {
    func sign(payload: JWTPayload, keyIdentifier: String) async throws -> String

    func verify<T: JWTPayload>(jwt: String, as: T.Type) async throws -> T
}

public final class LiveJWTFactory: JWTFactory {
    let keys: JWTKeyCollection

    public init() throws {
        keys = JWTKeyCollection()
    }

    public func addES256Key(pem: String, keyIdentifier: String) async throws {
        let kid = JWKIdentifier(string: keyIdentifier)
        let key = try ES256PrivateKey(pem: pem)
        await keys.add(ecdsa: key, kid: kid)
    }

    public func sign(payload: JWTPayload, keyIdentifier: String) async throws -> String {
        try await keys.sign(payload, kid: .init(string: keyIdentifier), header: ["typ": "JWT"])
    }

    public func verify<T: JWTPayload>(jwt: String, as payloadType: T.Type) async throws -> T {
        try await keys.verify(jwt, as: payloadType)
    }
}

public final class MockJWTFactory: JWTFactory {
    public func sign(payload _: JWTPayload, keyIdentifier _: String) async throws -> String {
        "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.tyh-VfuzIxCyGYDlkBA7DfyjrqmSHu6pQ2hoZuFqUSLPNY2N0mpHb3nk5K17HWP_3cYHBw7AhHale5wky6-sVA"
    }

    public func verify<T: JWTPayload>(jwt _: String, as _: T.Type) async throws -> T {
        throw SimpleMessageError(message: "MockJWTFactory does not implement `verify`")
    }
}

public final class UnimplementedJWTFactory: JWTFactory {
    public func sign(payload _: JWTPayload, keyIdentifier _: String) async throws -> String {
        throw SimpleMessageError(message: "Please override this at runtime")
    }

    public func verify<T: JWTPayload>(jwt _: String, as _: T.Type) async throws -> T {
        throw SimpleMessageError(message: "Please override this at runtime")
    }
}

public struct AppStoreConnectPayload: JWTPayload {
    public let iss: IssuerClaim
    public let iat: IssuedAtClaim
    public let exp: ExpirationClaim
    public let aud: AudienceClaim
    public let scope: [String]?

    public init(iss: String, iat: Date, exp: Date, aud: [String], scope: [String]? = nil) {
        self.iss = IssuerClaim(value: iss)
        self.iat = IssuedAtClaim(value: iat)
        self.exp = ExpirationClaim(value: exp)
        self.aud = AudienceClaim(value: aud)
        self.scope = scope
    }

    public func verify(using _: some JWTAlgorithm) throws {
        @Dependency(\.date) var date
        try exp.verifyNotExpired(currentDate: date.now)
    }
}
