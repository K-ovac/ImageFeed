//
//  AuthViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 18.12.2025.
//

import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String)
}
