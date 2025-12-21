//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 20.12.2025.
//

import UIKit
import Foundation

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
    
    var image: UIImage? {
        didSet {
            configureImageView()
        }
    }
    
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
        return imageView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: SingleImageConstants.Images.backward), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: SingleImageConstants.Images.sharing), for: .normal)
        button.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        configureImageView()
    }
    
    private func setupView() {
        view.backgroundColor = .ypBlack
        [scrollView, backButton, shareButton].forEach {
            view.addSubview($0)
        }
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
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                          constant: SingleImageConstants.backButtonInset),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                              constant: SingleImageConstants.backButtonInset),
            backButton.widthAnchor.constraint(equalToConstant: SingleImageConstants.backButtonSize.width),
            backButton.heightAnchor.constraint(equalToConstant: SingleImageConstants.backButtonSize.height),
            
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -SingleImageConstants.shareButtonBottomInset),
            shareButton.widthAnchor.constraint(equalToConstant: SingleImageConstants.shareButtonSize.width),
            shareButton.heightAnchor.constraint(equalToConstant: SingleImageConstants.shareButtonSize.height)
        ])
    }
    
    private func configureImageView() {
        guard isViewLoaded, let image else { return }
        
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage?) {
        guard let image else {
            return
        }
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    @objc private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapShareButton() {
        guard let image = imageView.image else { return }
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(activityVC, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
