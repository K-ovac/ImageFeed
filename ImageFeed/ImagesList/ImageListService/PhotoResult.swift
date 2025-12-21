//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 21.12.2025.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let created_at: String?
    let width: Int
    let height: Int
    let liked_by_user: Bool
    let description: String?
    let urls: UrlsResult
    
    struct UrlsResult: Decodable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
}
