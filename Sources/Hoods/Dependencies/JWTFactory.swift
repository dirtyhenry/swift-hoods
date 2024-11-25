import Blocks
import Dependencies
import Foundation
import JWTKit

// MARK: - Dependency Extension for JWTFactory

extension DependencyValues {
    /// Accessor for the JWTFactory dependency within DependencyValues.
    /// This provides access to the `JWTFactory` for signing and verifying JSON Web Tokens (JWTs).
    public var jwtFactory: JWTFactory {
        get { self[JWTFactoryKey.self] }
        set { self[JWTFactoryKey.self] = newValue }
    }

    private enum JWTFactoryKey: DependencyKey {
        /// The live implementation of `JWTFactory`. Defaults to `UnimplementedJWTFactory`.
        static let liveValue: JWTFactory = UnimplementedJWTFactory()

        #if DEBUG
        /// A mock implementation of `JWTFactory` for preview and test configurations.
        static let previewValue: JWTFactory = MockJWTFactory()
        static let testValue: JWTFactory = MockJWTFactory()
        #endif
    }
}

// MARK: - JWTFactory Protocol

/// A protocol defining methods for signing and verifying JSON Web Tokens (JWTs).
public protocol JWTFactory: Sendable {
    /// Signs the provided payload using a specific key identifier.
    /// - Parameters:
    ///   - payload: The JWT payload to sign.
    ///   - keyIdentifier: The identifier for the signing key.
    /// - Returns: A signed JWT as a string.
    func sign(payload: JWTPayload, keyIdentifier: String) async throws -> String

    /// Verifies a given JWT against the specified payload type.
    /// - Parameters:
    ///   - jwt: The JWT string to verify.
    ///   - as: The expected payload type conforming to `JWTPayload`.
    /// - Returns: An instance of the expected payload type.
    func verify<T: JWTPayload>(jwt: String, as: T.Type) async throws -> T
}

// MARK: - Live Implementation

/// A live implementation of `JWTFactory` using real cryptographic keys, using JWTKit.
///
/// ## Usage
///
/// ```swift
/// let factory = try LiveJWTFactory()
/// try await factory.addES256Key(pem: "<PEM_STRING>", keyIdentifier: "key-id")
///
/// let payload = AppStoreConnectPayload(
///     iss: "issuer-id",
///     iat: Date(),
///     exp: Date().addingTimeInterval(3600),
///     aud: ["app-store-connect"]
/// )
///
/// let signedJWT = try await factory.sign(payload: payload, keyIdentifier: "key-id")
/// ```
public final class LiveJWTFactory: JWTFactory {
    /// Collection of cryptographic keys for JWT operations.
    let keys: JWTKeyCollection

    /// Initializes the `LiveJWTFactory` with an empty key collection.
    public init() throws {
        keys = JWTKeyCollection()
    }

    /// Adds an ES256 key to the key collection.
    /// - Parameters:
    ///   - pem: The PEM-formatted key string.
    ///   - keyIdentifier: The identifier for the key.
    public func addES256Key(pem: String, keyIdentifier: String) async throws {
        let kid = JWKIdentifier(string: keyIdentifier)
        let key = try ES256PrivateKey(pem: pem)
        await keys.add(ecdsa: key, kid: kid)
    }

    /// Signs a JWT payload with a specific key identifier.
    public func sign(payload: JWTPayload, keyIdentifier: String) async throws -> String {
        try await keys.sign(payload, kid: .init(string: keyIdentifier), header: ["typ": "JWT"])
    }

    /// Verifies a JWT against a given payload type.
    public func verify<T: JWTPayload>(jwt: String, as payloadType: T.Type) async throws -> T {
        try await keys.verify(jwt, as: payloadType)
    }
}

// MARK: - Mock Implementation

/// A mock implementation of `JWTFactory` for testing purposes.
public final class MockJWTFactory: JWTFactory {
    public func sign(payload _: JWTPayload, keyIdentifier _: String) async throws -> String {
        "dummy-token"
    }

    public func verify<T: JWTPayload>(jwt _: String, as _: T.Type) async throws -> T {
        throw SimpleMessageError(message: "MockJWTFactory does not implement `verify`")
    }
}

// MARK: - Unimplemented Factory

/// An unimplemented factory used as a placeholder. Throws an error when any method is called.
public final class UnimplementedJWTFactory: JWTFactory {
    public func sign(payload _: JWTPayload, keyIdentifier _: String) async throws -> String {
        throw SimpleMessageError(message: "Please override this at runtime")
    }

    public func verify<T: JWTPayload>(jwt _: String, as _: T.Type) async throws -> T {
        throw SimpleMessageError(message: "Please override this at runtime")
    }
}

// MARK: - App Store Connect Payload

/// A JWT payload structure for App Store Connect APIs.
public struct AppStoreConnectPayload: JWTPayload {
    public let iss: IssuerClaim
    public let iat: IssuedAtClaim
    public let exp: ExpirationClaim
    public let aud: AudienceClaim
    public let scope: [String]?

    /// Creates a new payload for App Store Connect.
    public init(iss: String, iat: Date, exp: Date, aud: [String], scope: [String]? = nil) {
        self.iss = IssuerClaim(value: iss)
        self.iat = IssuedAtClaim(value: iat)
        self.exp = ExpirationClaim(value: exp)
        self.aud = AudienceClaim(value: aud)
        self.scope = scope
    }

    /// Verifies that the payload is valid and not expired.
    /// - Throws: An error if the payload is invalid or expired.
    public func verify(using _: some JWTAlgorithm) throws {
        @Dependency(\.date) var date
        try exp.verifyNotExpired(currentDate: date.now)
    }
}
