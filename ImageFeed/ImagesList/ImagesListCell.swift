//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 05.10.2025.
//

import UIKit
import Kingfisher

private enum ImagesListCellConstants {
    static let cornerRadius: CGFloat = 16
    static let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    static let likeButtonSize: CGSize = CGSize(width: 42, height: 42)
    static let dateLabelInsets = UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 0)
    static let dateLabelFontSize: CGFloat = 13
    
    enum Images {
        static let likeButtonOn = "likeButton"
        static let likeButtonOff = "noLikeButton"
    }
}

final class ImagesListCell: UITableViewCell {
    
    weak var delegate: ImagesListCellDelegate?
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - UI
    
    lazy var cellImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = ImagesListCellConstants.cornerRadius
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: ImagesListCellConstants.dateLabelFontSize)
        label.textColor = .ypWhite
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        button.accessibilityIdentifier = "likeButton"
        button.isHidden = true
        return button
    }()
    
    private var shimmerView: GradientLoadView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCellUI()
        setupConstraints()
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.image = nil
        dateLabel.text = nil
        likeButton.isHidden = true
        shimmerView?.removeFromSuperview()
        shimmerView = nil
    }
    
    // MARK: - Setup
    
    private func setupCellUI() {
        backgroundColor = .ypBlack
        selectionStyle = .none
        [cellImage, likeButton, dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: ImagesListCellConstants.imageInsets.top),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: ImagesListCellConstants.imageInsets.left),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -ImagesListCellConstants.imageInsets.right),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: -ImagesListCellConstants.imageInsets.bottom),
            
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: ImagesListCellConstants.likeButtonSize.width),
            likeButton.heightAnchor.constraint(equalToConstant: ImagesListCellConstants.likeButtonSize.height),
            
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor,
                                               constant: ImagesListCellConstants.dateLabelInsets.left),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor,
                                              constant: -ImagesListCellConstants.dateLabelInsets.bottom)
        ])
    }
    
    func setLikeButtonImage(isLiked: Bool) {
        let imageName = isLiked ? ImagesListCellConstants.Images.likeButtonOn : ImagesListCellConstants.Images.likeButtonOff
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    func showLoadCell() {
        likeButton.isHidden = true
        
        shimmerView?.removeFromSuperview()
        
        let shimmer = GradientLoadView.createShimmerView(frame: cellImage.bounds,
                                                     cornerRadius: ImagesListCellConstants.cornerRadius)
        cellImage.addSubview(shimmer)
        shimmer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shimmerView = shimmer
    }
    
    func hideLoadCell() {
        shimmerView?.removeFromSuperview()
        shimmerView = nil
        likeButton.isHidden = false
    }
    
    // MARK: - Actions
    
    @objc private func didTapLikeButton() {
        delegate?.imageListCellDidTapLike(self)
    }
}
