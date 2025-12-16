//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 14.12.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private enum Constants {
        static let avatarSize: CGFloat = 70
        static let buttonSize: CGFloat = 44
        static let largeInset: CGFloat = 32
        static let mediumInset: CGFloat = 16
        static let smallInset: CGFloat = 8
        static let nameFontSize: CGFloat = 23
        static let secondaryFontSize: CGFloat = 13
    }
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.accessibilityIdentifier = "avatarImageView"
        imageView.image = UIImage(named: "photo") ?? {
            let image = UIImage(systemName: "person.crop.circle.fill")
            imageView.tintColor = .ypGray
            return image
        }()
        
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = .systemFont(ofSize: Constants.nameFontSize, weight: .bold)
        label.textColor = .ypWhite
        label.accessibilityIdentifier = "nameLabel"
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = .systemFont(ofSize: Constants.secondaryFontSize)
        label.textColor = .ypGray
        label.accessibilityIdentifier = "loginNameLabel"
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = .systemFont(ofSize: Constants.secondaryFontSize)
        label.textColor = .ypWhite
        label.accessibilityIdentifier = "descriptionLabel"
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "logout") ?? UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                        for: .normal)
        button.tintColor = .ypRed
        button.accessibilityIdentifier = "logoutButton"
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileUI()
    }
    
    private func setupProfileUI() {
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                 constant: Constants.largeInset),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                     constant: Constants.mediumInset),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor,
                                           constant: Constants.smallInset),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -Constants.mediumInset),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor,
                                                constant: Constants.smallInset),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor,
                                                  constant: Constants.smallInset),
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: loginNameLabel.trailingAnchor),
            
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                   constant: -Constants.mediumInset),
            logoutButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            logoutButton.heightAnchor.constraint(equalTo: logoutButton.widthAnchor)
        ])
    }
    
    @objc private func didTapLogoutButton() {
        
    }
}
