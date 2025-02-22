import AsyncHTTPClient
import Foundation
import JWTKit
import NIOHTTP1

actor AuthClient {
    private let httpClient: HTTPClient
    private let teamID: String
    private let keyID: String
    private let key: String

    private var currentToken: TokenResponse?
    private var refreshTask: Task<TokenResponse, any Error>?

    init(httpClient: HTTPClient, teamID: String, keyID: String, key: String) {
        self.httpClient = httpClient
        self.teamID = teamID
        self.keyID = keyID
        self.key = key
    }

    var accessToken: String {
        get async throws {
            // If we're currently refreshing a token, await the value for our refresh task to make sure we return the refreshed token.
            if let refreshTask {
                return try await refreshTask.value.accessToken
            }

            // If we don't have a current token, we request a new one.
            guard let currentToken else {
                return try await self.newToken
            }

            if currentToken.isValid {
                return currentToken.accessToken
            }

            // None of the above applies so we'll need to refresh the token.
            return try await self.newToken
        }
    }

    private var newToken: String {
        get async throws {
            // If we're currently refreshing a token, await the value for our refresh task to make sure we return the refreshed token.
            if let refreshTask {
                return try await refreshTask.value.accessToken
            }

            // If we don't have a current token, we request a new one.
            let task = Task { () throws -> TokenResponse in
                defer { self.refreshTask = nil }
                let newToken = try await self.tokenResponse
                self.currentToken = newToken
                return newToken
            }

            self.refreshTask = task
            return try await task.value.accessToken
        }
    }
}

extension AuthClient {
    private var tokenResponse: TokenResponse {
        get async throws {
            var headers = HTTPHeaders()
            headers.add(name: "Authorization", value: "Bearer \(try await self.jwtToken)")

            var request = HTTPClientRequest(url: "\(AppleMapsClient.apiServer)/v1/token")
            request.headers = headers

            let response = try await httpClient.execute(request, timeout: .seconds(30))

            if response.status == .ok {
                return try await JSONDecoder().decode(TokenResponse.self, from: response.body.collect(upTo: 1024 * 1024))
            } else {
                throw try await JSONDecoder().decode(ErrorResponseJSON.self, from: response.body.collect(upTo: 1024 * 1024)).error
            }
        }
    }

    private var jwtToken: String {
        get async throws {
            let keys = try await JWTKeyCollection().add(ecdsa: ES256PrivateKey(pem: key))

            var header = JWTHeader()
            header.alg = "ES256"
            header.kid = keyID
            header.typ = "JWT"

            struct Payload: JWTPayload {
                let iss: IssuerClaim
                let iat: IssuedAtClaim
                let exp: ExpirationClaim

                func verify(using key: some JWTAlgorithm) throws {
                    try exp.verifyNotExpired()
                }
            }

            let payload = Payload(
                iss: IssuerClaim(value: teamID),
                iat: IssuedAtClaim(value: Date()),
                exp: ExpirationClaim(value: Date().addingTimeInterval(30 * 60))
            )

            return try await keys.sign(payload, header: header)
        }
    }
}
