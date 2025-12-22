//
//  Constants.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 17.12.2025.
//

import Foundation

enum Constants {
    static let accessKey = "jkej1SbFpca4fxP7KNcz31SBqaZaWEPIZ2vWtTq_8zA"
    static let secretKey = "okQDJWqt0bvLj-VtPyT7pr-SMXtB8OCp-QEJr83-Bxg"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    static var standard: AuthConfiguration {
        AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURL: Constants.defaultBaseURL,
            authURLString: Constants.unsplashAuthorizeURLString
        )
    }
}
