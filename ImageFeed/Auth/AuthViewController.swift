//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 17.12.2025.
//

import UIKit
import Foundation

final class AuthViewController: UIViewController {
    
    private enum SegueIdentifier {
        static let showWebView = "ShowWebView"
    }
    
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared
    
    @IBOutlet var authLogo: UIImageView!
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        
        loginButton.setTitle("Вход", for: .normal)
        
        loginButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        loginButton.titleLabel?.textAlignment = .center
        
        loginButton.setTitleColor(.ypBlack, for: .normal)
        loginButton.tintColor = .ypBlack
        loginButton.backgroundColor = .ypWhite
        
        loginButton.layer.cornerRadius = 16
        loginButton.layer.masksToBounds = true
        
        authLogo.image = UIImage(named: "auth_screen_logo")
        
        configureBackButton()
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
    
    @IBAction func loginButtonTapped() {
        print("Пользователь нажал кнопку Входа")
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        startAuthProcess()
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let token):
                self.handleAuthSuccess(token: token)
            case .failure(let error):
                self.handleAuthFailure(error: error)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        handleAuthCancellation()
    }
    
    private func startAuthProcess() {
        DispatchQueue.main.async {
            self.loginButton.isEnabled = false
            self.loginButton.alpha = 0.5
        }
    }
    
    private func endAuthProcess() {
        DispatchQueue.main.async {
            self.loginButton.isEnabled = true
            self.loginButton.alpha = 1.0
        }
    }
    
    private func handleAuthSuccess(token: String) {
        endAuthProcess()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.delegate?.authViewController(self, didAuthenticateWithToken: token)
        }
    }
    
    private func handleAuthFailure(error: Error) {
        endAuthProcess()
        DispatchQueue.main.async { [weak self] in
            self?.showAuthError(error)
            self?.dismiss(animated: true)
        }
    }
    
    private func handleAuthCancellation() {
        endAuthProcess()
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    private func showAuthError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка авторизации",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
