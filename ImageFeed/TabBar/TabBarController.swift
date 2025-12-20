//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 20.12.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTabBar()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.ypBlack
        tabBar.barTintColor = UIColor.ypBlack
        tabBar.tintColor = UIColor.ypWhite
        tabBar.unselectedItemTintColor = UIColor.ypGray
        tabBar.isTranslucent = false
    }
    
    private func setupTabBar() {
        guard let editorialImage = UIImage(named: "tab_editorial_active"),
              let profileImage = UIImage(named: "tab_profile_active") else {
            print("Missing tab bar images. Проверьте Assets.")
            return
        }
        
        let imagesListVC = ImagesListViewController()
        let profileVC = ProfileViewController()
        
        imagesListVC.tabBarItem = UITabBarItem(
            title: nil,
            image: editorialImage,
            tag: 0
        )
        
        profileVC.tabBarItem = UITabBarItem(
            title: nil,
            image: profileImage,
            tag: 1
        )
        
        viewControllers = [imagesListVC, profileVC]
    }
}
