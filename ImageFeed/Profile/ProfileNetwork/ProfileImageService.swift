//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 20.12.2025.
//

import Foundation

final class ProfileImageService {
    static let didChangeNotification = Notification.Name("ProfileImageServiceDidChange")
    static let shared = ProfileImageService()
    
    private init() {}
    
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var avatarURL: String?

    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        if let existingURL = avatarURL {
            completion(.success(existingURL))
            return
        }
        
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(URLError(.userAuthenticationRequired)))
            return
        }
        
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                let urlString = userResult.profile_image.small
                self?.avatarURL = urlString
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": urlString]
                )
                completion(.success(urlString))
                
            case .failure(let error):
                completion(.failure(error))
            }
            self?.task = nil
        }
        
        self.task = task
        task.resume()
    }
}
