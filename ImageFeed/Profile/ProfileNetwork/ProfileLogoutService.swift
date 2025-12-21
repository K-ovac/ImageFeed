//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 21.12.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        cleanAuthData()
        resetServicesData()
        switchToSplashScreen()
    }
    
    private func cleanAuthData() {
        OAuth2TokenStorage.shared.token = nil
    
        cleanWebViewData()
    }
    
    private func cleanWebViewData() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: Date.distantPast
        ) {
            print("Все данные WebView очищены")
        }
    }
    
    private func resetServicesData() {
        ProfileImageService.shared.resetAvatarURL()
        ImageListService.shared.resetPhotos()
    }
    
    private func switchToSplashScreen() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            
            let splashVC = SplashViewController()
            window.rootViewController = splashVC
            window.makeKeyAndVisible()
            
            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: nil
            )
        }
    }
}
