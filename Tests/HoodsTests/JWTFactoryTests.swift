import CryptoKit
import Dependencies
import Hoods
import JWTKit
import XCTest

class JWTFactoryTests: XCTestCase {
    func testInputByArgument() async throws {
        let privateKey = """
        -----BEGIN PRIVATE KEY-----
        MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgqIuh45D/4x9KGZ9v
        Ldw/u9jyWzYEwkR2GbsMv70vCuShRANCAATK9TcDMFQYh49HDnux2qzd3i2zdHFF
        uJcVQDj14FbV2QLpTbrNtk82W6ZMJT+FAZaJsx5Xiu9u83rbeICgZy3G
        -----END PRIVATE KEY-----
        """

        // -----BEGIN PUBLIC KEY-----
        // MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEyvU3AzBUGIePRw57sdqs3d4ts3Rx
        // RbiXFUA49eBW1dkC6U26zbZPNlumTCU/hQGWibMeV4rvbvN623iAoGctxg==
        // -----END PUBLIC KEY-----

        let iat = Date(timeIntervalSince1970: 1_528_407_600)
        let exp = iat.addingTimeInterval(60)
        print(iat.description)
        print(exp.description)
        let payload = AppStoreConnectPayload(
            iss: "57246542-96fe-1a63-e053-0824d011072a",
            iat: iat,
            exp: exp,
            aud: ["appstoreconnect-v1"],
            scope: ["GET /v1/apps/123"]
        )

        let jwtFactory = try LiveJWTFactory()
        try await jwtFactory.addES256Key(pem: privateKey, keyIdentifier: "2X9R4HXF34")
        let token = try await jwtFactory.sign(payload: payload, keyIdentifier: "2X9R4HXF34")
        print("Token: \(token)")
        let verifiedPayload = try await withDependencies {
            $0.date = DateGenerator.constant(Date(timeIntervalSince1970: 1_528_407_610))
        } operation: {
            try await jwtFactory.verify(jwt: token, as: AppStoreConnectPayload.self)
        }
        XCTAssertEqual(verifiedPayload.iss.value, "57246542-96fe-1a63-e053-0824d011072a")

        var verifyError: Error?
        do {
            try await withDependencies {
                $0.date = DateGenerator.constant(Date(timeIntervalSince1970: 1_528_407_661))
            } operation: {
                try await jwtFactory.verify(jwt: token, as: AppStoreConnectPayload.self)
            }
        } catch {
            verifyError = error
        }
        let verifyJWTError = try XCTUnwrap(verifyError) as? JWTError
        XCTAssertEqual(verifyJWTError?.reason, "expired")
    }
}
