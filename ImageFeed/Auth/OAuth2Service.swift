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
            debugPrint("Ошибка: не удалось создать URLComponents для https://unsplash.com/oauth/token")
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
            debugPrint("Ошибка: не удалось получить URL из URLComponents")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        debugPrint("URLRequest успешно создан: \(request)")
        return request
    }

    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            let error = NetworkError.invalidRequest
            debugPrint("Ошибка: не удалось создать URLRequest для OAuth-токена. \(error)")
            completion(.failure(error))
            return
        }

        debugPrint("Начинаем сетевой запрос для получения OAuth-токена")

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                debugPrint("Сетевая ошибка при запросе OAuth-токена: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                debugPrint("Ошибка: данные от сервера отсутствуют")
                completion(.failure(NetworkError.invalidRequest))
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(OAuthTokenResponse.self, from: data)
                let token = response.accessToken

                OAuth2TokenStorage.shared.token = token
                debugPrint("OAuth-токен успешно получен: \(token)")
                completion(.success(token))
            } catch {
                debugPrint("Ошибка декодирования ответа OAuth-токена: \(error.localizedDescription)")
                completion(.failure(NetworkError.decodingError(error)))
            }
        }

        task.resume()
    }
}
