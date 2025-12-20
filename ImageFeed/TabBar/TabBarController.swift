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
        guard let editorialActive = UIImage(named: "tab_editorial_active"),
              let editorialInactive = UIImage(named: "tab_editorial_no_active"),
              let profileActive = UIImage(named: "tab_profile_active"),
              let profileInactive = UIImage(named: "tab_profile_no_active") else {
            print("Missing tab bar images. Проверьте Assets.")
            return
        }
        
        let imagesListVC = ImagesListViewController()
        let profileVC = ProfileViewController()
        
        let editorialTabBarItem = UITabBarItem(
            title: nil,
            image: editorialInactive,
            selectedImage: editorialActive
        )
        editorialTabBarItem.tag = 0
        imagesListVC.tabBarItem = editorialTabBarItem
        
        let profileTabBarItem = UITabBarItem(
            title: nil,
            image: profileInactive,
            selectedImage: profileActive
        )
        profileTabBarItem.tag = 1
        profileVC.tabBarItem = profileTabBarItem
        
        viewControllers = [imagesListVC, profileVC]
    }

}
