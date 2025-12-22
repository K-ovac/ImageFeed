//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Максим Лозебной on 22.12.2025.
//

import Foundation

public protocol WebViewPresenterProtocol: AnyObject {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let progressValue = Float(newValue)
        view?.setProgressValue(progressValue)
        view?.setProgressHidden(abs(progressValue - 1.0) <= 0.0001)
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
