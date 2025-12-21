//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 17.12.2025.
//

import Foundation

enum OAuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    private let session = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
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
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(OAuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(OAuthServiceError.invalidRequest))
            return
        }
        
        let task = session.objectTask(for: request) { [weak self]
            (result: Result<OAuthTokenResponse, Error>) in
            
            defer {
                self?.task = nil
                self?.lastCode = nil
            }
            
            switch result {
            case .success(let response):
                let token = response.accessToken
                OAuth2TokenStorage.shared.token = token
                completion(.success(token))
                
            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken]: error=\(error), code=\(code)")
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
}
