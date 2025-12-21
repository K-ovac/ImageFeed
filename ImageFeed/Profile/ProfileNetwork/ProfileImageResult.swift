//
//  ProfileImageResult.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 20.12.2025.
//

struct UserResult: Codable {
    struct ProfileImage: Codable {
        let small: String
    }
    let profile_image: ProfileImage
}
