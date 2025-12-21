//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 02.10.2025.
//

import UIKit
import Kingfisher

private enum ImagesListConstants {
    static let defaultCellHeight: CGFloat = 200
    static let tableViewContentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    static let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

final class ImagesListViewController: UIViewController {
    
    private var photos: [Photo] = []
    private var imageSizes: [CGSize] = []
    private let imagesListService = ImageListService.shared
    private let refreshControl = UIRefreshControl()
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlack
        tableView.contentInset = ImagesListConstants.tableViewContentInset
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupRefreshControl()
        setupNotificationObserver()
        fetchInitialPhotos()
    }
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupView() {
        view.backgroundColor = .ypBlack
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupRefreshControl() {
        refreshControl.tintColor = .ypWhite
        refreshControl.addTarget(self, action: #selector(refreshPhotos(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePhotosChanged(_:)),
            name: ImageListService.didChangeNotification,
            object: nil
        )
    }
    
    private func fetchInitialPhotos() {
        UIBlockingProgressHUD.show()
        imagesListService.fetchPhotosNextPage()
    }
    
    @objc private func refreshPhotos(_ sender: Any) {
        photos.removeAll()
        imageSizes.removeAll()
        tableView.reloadData()
        imagesListService.resetPhotos()
        imagesListService.fetchPhotosNextPage()
    }
    
    @objc private func handlePhotosChanged(_ notification: Notification) {
        let newPhotos = imagesListService.photos
        let uniqueNewPhotos = newPhotos.filter { newPhoto in
            !photos.contains { $0.id == newPhoto.id }
        }
        
        if !uniqueNewPhotos.isEmpty {
            let startIndex = photos.count
            photos.append(contentsOf: uniqueNewPhotos)
            imageSizes.append(contentsOf: uniqueNewPhotos.map { $0.size })
            let endIndex = photos.count - 1
            let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }
            
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
        
        UIBlockingProgressHUD.dismiss()
        refreshControl.endRefreshing()
    }
    
    private func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }
        let photo = photos[indexPath.row]
        
        cell.showLoadCell()
        
        cell.cellImage.kf.setImage(
            with: photo.thumbImageURL,
            placeholder: nil,
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ]
        ) { [weak cell] result in
            DispatchQueue.main.async {
                guard let cell = cell else { return }
                
                switch result {
                case .success:
                    cell.cellImage.contentMode = .scaleAspectFill
                case .failure:
                    cell.cellImage.contentMode = .center
                    cell.cellImage.image = UIImage(named: "placeholder")
                }
                
                cell.hideLoadCell()
                cell.setLikeButtonImage(isLiked: photo.isLiked)
                cell.dateLabel.text = photo.createdAt.map {
                    ImagesListConstants.dateFormatter.string(from: $0)
                }
            }
        }
    }
    
    private func calculateCellHeight(for indexPath: IndexPath) -> CGFloat {
        let imageViewWidth = tableView.bounds.width - ImagesListConstants.imageInsets.left - ImagesListConstants.imageInsets.right
        guard indexPath.row < imageSizes.count else { return ImagesListConstants.defaultCellHeight }
        let imageSize = imageSizes[indexPath.row]
        let scaleRatio = imageViewWidth / imageSize.width
        return imageSize.height * scaleRatio + ImagesListConstants.imageInsets.top + ImagesListConstants.imageInsets.bottom
    }
}

    // MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { photos.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        configureCell(cell, at: indexPath)
        return cell
    }
}

    // MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        calculateCellHeight(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleVC = SingleImageViewController()
        singleVC.imageURL = photos[indexPath.row].largeImageURL
        singleVC.modalPresentationStyle = .fullScreen
        present(singleVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

    // MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        print("Пользователь нажал на лайк для фото id: \(photo.id), текущее состояние isLiked: \(photo.isLiked)")
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                
                switch result {
                case .success(let updatedPhoto):
                    self.photos[indexPath.row] = updatedPhoto
                    cell.setLikeButtonImage(isLiked: updatedPhoto.isLiked)
                    
                    if updatedPhoto.isLiked {
                        print("Лайк установлен для фото id: \(updatedPhoto.id)")
                    } else {
                        print("Лайк снят для фото id: \(updatedPhoto.id)")
                    }
                    
                case .failure(let error):
                    print("Ошибка при установке лайка для фото id: \(photo.id). Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }
}
