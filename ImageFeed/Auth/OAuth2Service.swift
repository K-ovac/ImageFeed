//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 17.12.2025.
//

import Foundation

final class OAuth2Service {

    static let shared = OAuth2Service()
    private init() {}

    private let session = URLSession.shared

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var components = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let url = components.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }

    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let task = session.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponse.self, from: data)
                    let token = response.accessToken

                    OAuth2TokenStorage.shared.token = token
                    completion(.success(token))
                } catch {
                    print(error)
                    completion(.failure(NetworkError.decodingError(error)))
                }

            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
