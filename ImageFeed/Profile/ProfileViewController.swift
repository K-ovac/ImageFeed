//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 14.12.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private var isLoadingProfile = true
    
    // MARK: - UI
    
    private enum UIConstants {
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
        imageView.image = UIImage(named: "avatarPhoto") ?? UIImage(systemName: "person.crop.circle.fill")
        imageView.tintColor = .ypGray
        imageView.layer.cornerRadius = UIConstants.avatarSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.nameFontSize, weight: .bold)
        label.textColor = .ypWhite
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.secondaryFontSize)
        label.textColor = .ypGray
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.secondaryFontSize)
        label.textColor = .ypWhite
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "logoutButton") ?? UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        button.tintColor = .ypRed
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        return button
    }()
    
    private var avatarShimmer: GradientLoadView?
    private var nameShimmer: GradientLoadView?
    private var loginShimmer: GradientLoadView?
    private var descriptionShimmer: GradientLoadView?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileUI()
        applyShimmers()
        loadProfile()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveAvatarUpdate),
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isLoadingProfile {
            [avatarShimmer, nameShimmer, loginShimmer, descriptionShimmer].forEach { $0?.frame = $0?.superview?.bounds ?? .zero }
        }
    }
    
    // MARK: - Setup
    
    private func setupProfileUI() {
        view.backgroundColor = .ypBlack
        
        [avatarImageView, nameLabel, loginNameLabel, descriptionLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: UIConstants.largeInset),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: UIConstants.mediumInset),
            avatarImageView.widthAnchor.constraint(equalToConstant: UIConstants.avatarSize),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: UIConstants.smallInset),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.mediumInset),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: UIConstants.smallInset),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: UIConstants.smallInset),
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: loginNameLabel.trailingAnchor),
            
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -UIConstants.mediumInset),
            logoutButton.widthAnchor.constraint(equalToConstant: UIConstants.buttonSize),
            logoutButton.heightAnchor.constraint(equalTo: logoutButton.widthAnchor)
        ])
    }
    
    private func applyShimmers() {
        avatarShimmer = GradientLoadView.createShimmerView(frame: avatarImageView.bounds, cornerRadius: UIConstants.avatarSize / 2)
        avatarImageView.addSubview(avatarShimmer!)
        avatarShimmer?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        nameShimmer = GradientLoadView.createShimmerView(frame: nameLabel.bounds, cornerRadius: 4)
        nameLabel.addSubview(nameShimmer!)
        nameShimmer?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        loginShimmer = GradientLoadView.createShimmerView(frame: loginNameLabel.bounds, cornerRadius: 4)
        loginNameLabel.addSubview(loginShimmer!)
        loginShimmer?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        descriptionShimmer = GradientLoadView.createShimmerView(frame: descriptionLabel.bounds, cornerRadius: 4)
        descriptionLabel.addSubview(descriptionShimmer!)
        descriptionShimmer?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func removeShimmers() {
        [avatarShimmer, nameShimmer, loginShimmer, descriptionShimmer].forEach { $0?.removeFromSuperview() }
    }
    
    private func loadProfile() {
        guard let profile = profileService.profile else { return }
        updateProfileDetails(with: profile)
        
        if let avatarURL = ProfileImageService.shared.avatarURL {
            updateAvatar(from: avatarURL)
        } else {
            ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { [weak self] result in
                DispatchQueue.main.async {
                    if case .success(let urlString) = result {
                        self?.updateAvatar(from: urlString)
                    }
                }
            }
        }
    }
    
    private func updateAvatar(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let processor = DownsamplingImageProcessor(size: CGSize(width: UIConstants.avatarSize * 2,
                                                                height: UIConstants.avatarSize * 2))
                        |> RoundCornerImageProcessor(cornerRadius: UIConstants.avatarSize / 2)
        
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "person.crop.circle.fill"),
            options: [.processor(processor), .scaleFactor(UIScreen.main.scale), .cacheOriginalImage]
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.avatarShimmer?.removeFromSuperview()
                self?.avatarShimmer = nil
            }
        }
    }
    
    private func updateProfileDetails(with profile: Profile) {
        nameLabel.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        loginNameLabel.text = profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio
        isLoadingProfile = false
        
        nameShimmer?.removeFromSuperview()
        loginShimmer?.removeFromSuperview()
        descriptionShimmer?.removeFromSuperview()
    }
    
    // MARK: - Actions
    
    @objc private func didReceiveAvatarUpdate(_ notification: Notification) {
        guard let urlString = notification.userInfo?["URL"] as? String else { return }
        updateAvatar(from: urlString)
    }
    
    @objc private func didTapLogoutButton() {
        let alert = UIAlertController(title: "Пока, пока!",
                                      message: "Уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { _ in
            ProfileLogoutService.shared.logout()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        present(alert, animated: true)
    }
}
