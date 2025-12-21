//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 17.12.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private init() {
        debugPrint("OAuth2TokenStorage инициализирован")
    }
    
    private enum Keys {
        static let token = "OAuth2Token"
    }
    
    var token: String? {
        get {
            if let token = KeychainWrapper.standard.string(forKey: Keys.token) {
                debugPrint("Токен существует в Keychain")
                return token
            } else {
                debugPrint("Токен отсутствует в Keychain")
                return nil
            }
        }
        set {
            if let token = newValue, token != KeychainWrapper.standard.string(forKey: Keys.token) {
                KeychainWrapper.standard.set(token, forKey: Keys.token)
                debugPrint("Токен успешно сохранен в Keychain")
            } else if newValue == nil {
                KeychainWrapper.standard.removeObject(forKey: Keys.token)
                debugPrint("Токен удален из Keychain")
            }
        }
    }

    
    func logKeychainStatus() {
        let status = token != nil ? "Токен существует" : "Токен отсутствует"
        debugPrint("Статус Keychain: \(status)")
    }
}
