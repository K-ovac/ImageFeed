//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 17.12.2025.
//

import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    
    // MARK: - Dependencies
    
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared
    
    // MARK: - UI
    
    private let authLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "auth_screen_logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вход", for: .normal)
        button.setTitleColor(.ypBlack, for: .normal)
        button.backgroundColor = .ypWhite
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAuthVC()
    }
    
    // MARK: - Setup
    
    private func configureAuthVC() {
        view.backgroundColor = .ypBlack
        
        view.addSubview(authLogo)
        view.addSubview(loginButton)
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            authLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            authLogo.widthAnchor.constraint(equalToConstant: 60),
            authLogo.heightAnchor.constraint(equalToConstant: 60),
            
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func loginButtonTapped() {
        debugPrint("Пользователь нажал кнопку Входа")
        showWebViewController()
    }
    
    private func showWebViewController() {
        let webVC = WebViewViewController()
        webVC.delegate = self
        let navVC = UINavigationController(rootViewController: webVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController,
                               didAuthenticateWithCode code: String) {
        startAuthProcess()
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                self.endAuthProcess()
                
                switch result {
                case .success(let token):
                    self.handleAuthSuccess(token: token)
                case .failure(let error):
                    self.handleAuthFailure(error: error)
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        DispatchQueue.main.async {
            self.endAuthProcess()
            self.dismiss(animated: true)
        }
    }
    
    private func startAuthProcess() {
        DispatchQueue.main.async {
            self.loginButton.isEnabled = false
            self.loginButton.alpha = 0.5
            UIBlockingProgressHUD.show()
        }
    }
    
    private func endAuthProcess() {
        self.loginButton.isEnabled = true
        self.loginButton.alpha = 1.0
    }
    
    private func handleAuthSuccess(token: String) {
        OAuth2TokenStorage.shared.token = token
        delegate?.authViewController(self, didAuthenticateWithToken: token)
    }
    
    private func handleAuthFailure(error: Error) {
        showAuthError(error)
    }

    private func showAuthError(_ error: Error) {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        
        present(alert, animated: true)
    }
}
