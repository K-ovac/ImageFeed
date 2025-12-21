//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 18.12.2025.
//

import UIKit

final class SplashViewController: UIViewController {

    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared

    private let splashLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "launchScreenLogo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        view.addSubview(splashLogo)
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkTokenAndNavigate()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            splashLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashLogo.widthAnchor.constraint(equalToConstant: 120),
            splashLogo.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    private func checkTokenAndNavigate() {
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            showAuthScreen()
        }
    }

    private func showAuthScreen() {
        let authVC = AuthViewController()
        authVC.delegate = self
        let navVC = UINavigationController(rootViewController: authVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: false)
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }

                switch result {
                case .success(let profile):
                    ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in
                        DispatchQueue.main.async {
                            self.switchToTabBarController()
                        }
                    }
                case .failure(let error):
                    print("Error fetching profile: \(error)")
                    self.showAuthScreen()
                }
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String) {
        storage.token = token
        vc.dismiss(animated: true) { [weak self] in
            self?.fetchProfile(token: token)
        }
    }
}
