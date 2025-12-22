//
//  WebViewTest.swift
//  WebViewTest
//
//  Created by Максим Лозебной on 22.12.2025.
//

import XCTest
@testable import ImageFeed

@MainActor
final class WebViewTests: XCTestCase {

    final class WebViewPresenterSpy: WebViewPresenterProtocol {
        var viewDidLoadCalled = false
        var view: WebViewViewControllerProtocol?

        func viewDidLoad() {
            viewDidLoadCalled = true
        }

        func didUpdateProgressValue(_ newValue: Double) {}
        func code(from url: URL) -> String? { nil }
    }

    @MainActor
    final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
        var presenter: WebViewPresenterProtocol?
        var loadRequestCalled = false
        var setProgressValueCalled = false
        var setProgressHiddenCalled = false
        var lastProgressHidden: Bool?

        func load(request: URLRequest) {
            loadRequestCalled = true
        }

        func setProgressValue(_ newValue: Float) {
            setProgressValueCalled = true
        }

        func setProgressHidden(_ isHidden: Bool) {
            setProgressHiddenCalled = true
            lastProgressHidden = isHidden
        }
    }

    func testViewControllerCallsViewDidLoad() {
        let presenter = WebViewPresenterSpy()
        let viewController = WebViewViewControllerSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        _ = viewController.presenter?.viewDidLoad()

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsLoadRequest() {
        let viewController = WebViewViewControllerSpy()
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        viewController.presenter = presenter
        presenter.view = viewController

        presenter.viewDidLoad()

        XCTAssertTrue(viewController.loadRequestCalled)
    }

    func testProgressVisibleWhenLessThenOne() {
        let viewController = WebViewViewControllerSpy()
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        presenter.view = viewController

        presenter.didUpdateProgressValue(0.6)

        XCTAssertTrue(viewController.setProgressHiddenCalled)
        XCTAssertEqual(viewController.lastProgressHidden, false)
    }

    func testProgressHiddenWhenOne() {
        let viewController = WebViewViewControllerSpy()
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        presenter.view = viewController

        presenter.didUpdateProgressValue(1.0)

        XCTAssertTrue(viewController.setProgressHiddenCalled)
        XCTAssertEqual(viewController.lastProgressHidden, true)
    }

    func testAuthHelperAuthRequest() {
        let helper = AuthHelper()
        let request = helper.authRequest()
        let urlString = request?.url?.absoluteString ?? ""

        let config = AuthConfiguration.standard
        XCTAssertTrue(urlString.contains(config.authURLString))
        XCTAssertTrue(urlString.contains(config.accessKey))
        XCTAssertTrue(urlString.contains(config.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(config.accessScope))
    }

    func testCodeFromURL() {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let helper = AuthHelper()

        let code = helper.code(from: url)
        XCTAssertEqual(code, "test code")
    }
}
