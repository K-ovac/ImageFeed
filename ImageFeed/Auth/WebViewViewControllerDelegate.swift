//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 17.12.2025.
//

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
