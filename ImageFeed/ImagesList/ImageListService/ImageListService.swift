//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 21.12.2025.
//

import Foundation
import UIKit

final class ImageListService {
    
    static let shared = ImageListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    private let perPage = 10
    
    private init() {}
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard currentTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard
            let token = tokenStorage.token,
            let request = makePhotosRequest(page: nextPage, perPage: perPage, token: token)
        else {
            print("[ImageListService.fetchPhotosNextPage]: RequestCreationError, page=\(nextPage), tokenAvailable=\(tokenStorage.token != nil)")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let results):
                let newPhotos = results.compactMap { self.makePhoto(from: $0) }
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                
                NotificationCenter.default.post(
                    name: ImageListService.didChangeNotification,
                    object: self
                )
                
            case .failure(let error):
                print("[ImageListService.fetchPhotosNextPage]: Failure, page=\(nextPage), error=\(error)")
            }
            
            self.currentTask = nil
        }
        
        self.currentTask = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Photo, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard currentTask == nil else {
            let error = NSError(domain: "DuplicateRequest", code: 1)
            print("[ImageListService.changeLike]: DuplicateRequest, photoId=\(photoId), isLike=\(isLike), error=\(error)")
            completion(.failure(error))
            return
        }
        
        guard let token = tokenStorage.token else {
            let error = NSError(domain: "Unauthorized", code: 1)
            print("[ImageListService.changeLike]: Unauthorized, photoId=\(photoId), isLike=\(isLike), error=\(error)")
            completion(.failure(error))
            return
        }
        
        let httpMethod = isLike ? "POST" : "DELETE"
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "InvalidRequest", code: 1)
            print("[ImageListService.changeLike]: InvalidRequest, photoId=\(photoId), isLike=\(isLike), urlString=\(urlString), error=\(error)")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.currentTask = nil }
            
            if let error = error {
                print("[ImageListService.changeLike]: NetworkError, photoId=\(photoId), isLike=\(isLike), error=\(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let bodyString = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                print("[ImageListService.changeLike]: HTTPError, photoId=\(photoId), isLike=\(isLike), statusCode=\((response as? HTTPURLResponse)?.statusCode ?? 0), body=\(bodyString)")
                DispatchQueue.main.async { completion(.failure(NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? 0))) }
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "NoData", code: 1)
                print("[ImageListService.changeLike]: NoData, photoId=\(photoId), isLike=\(isLike), error=\(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            struct LikeResponse: Decodable { let photo: PhotoResult }
            
            do {
                let likeResponse = try JSONDecoder().decode(LikeResponse.self, from: data)
                guard let updatedPhoto = self.makePhoto(from: likeResponse.photo) else {
                    let error = NSError(domain: "InvalidResponse", code: 1)
                    print("[ImageListService.changeLike]: InvalidResponse, photoId=\(photoId), isLike=\(isLike), error=\(error), data=\(String(data: data, encoding: .utf8) ?? "")")
                    DispatchQueue.main.async { completion(.failure(error)) }
                    return
                }
                
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    self.photos[index] = updatedPhoto
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
                        completion(.success(updatedPhoto))
                    }
                } else {
                    let error = NSError(domain: "PhotoNotFound", code: 1)
                    print("[ImageListService.changeLike]: PhotoNotFound, photoId=\(photoId), isLike=\(isLike), error=\(error)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
                
            } catch {
                print("[ImageListService.changeLike]: DecodingError, photoId=\(photoId), isLike=\(isLike), error=\(error), data=\(String(data: data, encoding: .utf8) ?? "")")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
        
        self.currentTask = task
        task.resume()
    }
    
    
    func resetPhotos() {
        photos = []
        lastLoadedPage = nil
        NotificationCenter.default.post(
            name: ImageListService.didChangeNotification,
            object: self
        )
    }
}

private extension ImageListService {
    func makePhotosRequest(page: Int, perPage: Int, token: String) -> URLRequest? {
        guard var components = URLComponents(string: "https://api.unsplash.com/photos") else { return nil }
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func makePhoto(from result: PhotoResult) -> Photo? {
        guard
            let thumbURL = URL(string: result.urls.thumb),
            let largeURL = URL(string: result.urls.full)
        else { return nil }
        
        let urls = Photo.Urls(
            raw: result.urls.raw,
            full: result.urls.full,
            regular: result.urls.regular,
            small: result.urls.small,
            thumb: result.urls.thumb
        )
        
        let createdAtDate = result.created_at.flatMap { ISO8601DateFormatter().date(from: $0) }
        
        return Photo(
            id: result.id,
            size: CGSize(width: result.width, height: result.height),
            createdAt: createdAtDate,
            welcomeDescription: result.description,
            thumbImageURL: thumbURL,
            largeImageURL: largeURL,
            urls: urls,
            isLiked: result.liked_by_user
        )
    }
    
    func parseDate(from string: String?) -> Date? {
        guard let string = string else { return nil }
        return ISO8601DateFormatter().date(from: string)
    }
}
