//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 02.10.2025.
//
import UIKit

// MARK: - Constants
private enum ImagesListConstants {
    static let defaultCellHeight: CGFloat = 200
    static let tableViewContentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    static let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    static let photosCount = 20
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}

// MARK: - ImagesListViewController
final class ImagesListViewController: UIViewController {

    // MARK: - Properties
    private let currentDate = Date()
    private var photosName = [String]()
    private var imageSizes = [CGSize]()

    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlack
        tableView.contentInset = ImagesListConstants.tableViewContentInset
        tableView.estimatedRowHeight = ImagesListConstants.defaultCellHeight
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPhotosAndSizes()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .ypBlack
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadPhotosAndSizes() {
        photosName = (0..<ImagesListConstants.photosCount).compactMap { index in
            let name = "\(index)" // твои имена изображений
            guard let image = UIImage(named: name) else {
                print("Missing image: \(name)")
                return nil
            }
            imageSizes.append(image.size)
            return name
        }
    }

    private func calculateCellHeight(for imageSize: CGSize) -> CGFloat {
        let imageViewWidth = tableView.bounds.width - ImagesListConstants.imageInsets.left - ImagesListConstants.imageInsets.right
        let scaleRatio = imageViewWidth / imageSize.width
        let imageViewHeight = imageSize.height * scaleRatio
        return imageViewHeight + ImagesListConstants.imageInsets.top + ImagesListConstants.imageInsets.bottom
    }

    private func configureCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let photoName = photosName[indexPath.row]
        guard let image = UIImage(named: photoName) else { return }
        
        cell.cellImage.image = image

        let dateString = ImagesListConstants.dateFormatter.string(from: currentDate)
            .replacingOccurrences(of: " г.", with: "")
            .replacingOccurrences(of: "г.", with: "")
        cell.dateLabel.text = dateString

        let isLiked = indexPath.row % 2 == 0
        cell.setLikeButtonImage(isLiked: isLiked)

        DispatchQueue.main.async {
            cell.setupGradient()
        }
    }

    private func showSingleImage(at indexPath: IndexPath) {
        let singleVC = SingleImageViewController()
        singleVC.image = UIImage(named: photosName[indexPath.row])
        singleVC.modalPresentationStyle = .fullScreen
        present(singleVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }

        configureCell(cell, at: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageSize = imageSizes[indexPath.row]
        return calculateCellHeight(for: imageSize)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showSingleImage(at: indexPath)
    }
}
