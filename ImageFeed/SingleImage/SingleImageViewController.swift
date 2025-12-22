//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 20.12.2025.
//

import UIKit
import Kingfisher

private enum SingleImageConstants {
    static let backButtonSize = CGSize(width: 44, height: 44)
    static let backButtonInset: CGFloat = 8
    static let shareButtonSize = CGSize(width: 50, height: 50)
    static let shareButtonBottomInset: CGFloat = 17
    static let minZoomScale: CGFloat = 0.1
    static let maxZoomScale: CGFloat = 1.25
    
    enum Images {
        static let backward = "backButton"
        static let sharing = "shareButton"
    }
}

final class SingleImageViewController: UIViewController {
    
    var imageURL: URL? {
        didSet { loadImage() }
    }
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = SingleImageConstants.minZoomScale
        scrollView.maximumZoomScale = SingleImageConstants.maxZoomScale
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "fullScreennImage"
        return imageView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: SingleImageConstants.Images.backward), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "backButton"
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: SingleImageConstants.Images.sharing), for: .normal)
        button.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "shareButton"
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        loadImage()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .ypBlack
        [scrollView, backButton, shareButton].forEach { view.addSubview($0) }
        scrollView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: SingleImageConstants.backButtonInset),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: SingleImageConstants.backButtonInset),
            backButton.widthAnchor.constraint(equalToConstant: SingleImageConstants.backButtonSize.width),
            backButton.heightAnchor.constraint(equalToConstant: SingleImageConstants.backButtonSize.height),
            
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -SingleImageConstants.shareButtonBottomInset),
            shareButton.widthAnchor.constraint(equalToConstant: SingleImageConstants.shareButtonSize.width),
            shareButton.heightAnchor.constraint(equalToConstant: SingleImageConstants.shareButtonSize.height)
        ])
    }
    
    private func loadImage() {
        guard let imageURL else { return }
        UIBlockingProgressHUD.show()

        let placeholder = UIImage(named: "placeholder")
        imageView.kf.setImage(
            with: imageURL,
            placeholder: placeholder,
            options: [
                .transition(.fade(0.25)),
                .cacheOriginalImage
            ]) { [weak self] result in
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    guard let self = self else { return }
                    switch result {
                    case .success(let value):
                        self.imageView.image = value.image
                        self.rescaleAndCenterImageInScrollView(image: value.image)
                    case .failure:
                        self.imageView.image = placeholder
                        self.imageView.contentMode = .center
                        self.rescaleAndCenterImageInScrollView(image: placeholder)
                    }
                }
            }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage?) {
        guard let image else { return }
        let minZoom = scrollView.minimumZoomScale
        let maxZoom = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        
        let visibleSize = scrollView.bounds.size
        let hScale = visibleSize.width / image.size.width
        let vScale = visibleSize.height / image.size.height
        let scale = min(maxZoom, max(minZoom, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        
        scrollView.layoutIfNeeded()
        let contentSize = scrollView.contentSize
        let x = (contentSize.width - visibleSize.width) / 2
        let y = (contentSize.height - visibleSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    // MARK: - Actions
    
    @objc private func didTapBackButton() {
        dismiss(animated: true)
    }
    @objc private func didTapShareButton() {
        guard let image = imageView.image else { return }
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(vc, animated: true)
    }
}

    // MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
}
