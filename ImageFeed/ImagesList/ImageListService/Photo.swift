//
//  Photo.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 21.12.2025.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: URL
    let largeImageURL: URL
    let urls: Urls
    var isLiked: Bool
    
    struct Urls {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
}
