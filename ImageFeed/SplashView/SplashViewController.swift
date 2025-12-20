//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 18.12.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    
    private let storage = OAuth2TokenStorage.shared
    
    @IBOutlet var splashScreenLogo: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.backgroundColor = .ypBlack
        
        splashScreenLogo.image = UIImage(named: "launchScreenLogo")
        
        if storage.token != nil {
            switchToTabBarController()
        } else {
            showAuthScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func showAuthScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authVC = storyboard.instantiateViewController(
            withIdentifier: "AuthViewController") as? AuthViewController else { return }
        
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
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let tabBarController = storyboard.instantiateViewController(
            withIdentifier: "TabBarViewController") as? UITabBarController else { return }
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String) {
        storage.token = token
        
        vc.dismiss(animated: false) { [weak self] in
            self?.switchToTabBarController()
        }
    }
}
