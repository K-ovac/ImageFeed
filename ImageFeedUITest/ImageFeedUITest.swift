//
//  ImageFeedUITest.swift
//  ImageFeedUITest
//
//  Created by Максим Лозебной on 22.12.2025.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    private enum Identifiers {
        static let loginButton = "loginButton"
        static let webView = "UnsplashWebView"
        static let likeButton = "likeButton"
        static let backButton = "backButton"
        static let logoutButton = "logoutButton"
        static let profileName = "usernameLabel"
        static let profileLogin = "loginNameLabel"
    }
    
    private enum TestData {
        static let email = "email@example.com"
        static let password = "password"
        static let userName = ""
        static let userLogin = ""
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDownWithError() throws {
    }
    
    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 10) {
        let predicate = NSPredicate(format: "exists == true")
        expectation(for: predicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    
    func testAuth() throws {
        let authButton = app.buttons[Identifiers.loginButton]
        waitForElement(authButton)
        authButton.tap()
        
        let webView = app.webViews[Identifiers.webView]
        waitForElement(webView)
        
        let emailField = webView.textFields.element
        waitForElement(emailField)
        emailField.tap()
        emailField.typeText(TestData.email)
        
        let passwordField = webView.secureTextFields.element
        waitForElement(passwordField)
        passwordField.tap()
        UIPasteboard.general.string = TestData.password
        passwordField.doubleTap()
        if app.menuItems["Paste"].waitForExistence(timeout: 3) {
            app.menuItems["Paste"].tap()
        } else {
            passwordField.typeText(TestData.password)
        }
        
        if app.toolbars.buttons["Done"].waitForExistence(timeout: 3) {
            app.toolbars.buttons["Done"].tap()
        }
        
        let loginButton = webView.buttons["Login"]
        waitForElement(loginButton)
        loginButton.tap()
        
        let firstCell = app.tables.cells.element(boundBy: 0)
        waitForElement(firstCell)
    }
    
    @MainActor
    func testFeed() throws {
        let tables = app.tables
        let firstCell = tables.cells.element(boundBy: 0)
        waitForElement(firstCell)
        
        let cellToLike = tables.cells.element(boundBy: 1)
        waitForElement(cellToLike)
        let likeButton = cellToLike.buttons[Identifiers.likeButton]
        waitForElement(likeButton)
        likeButton.tap()
        likeButton.tap()
        
        cellToLike.tap()
        let fullScreenImage = app.scrollViews.images.element(boundBy: 0)
        waitForElement(fullScreenImage)
        
        fullScreenImage.pinch(withScale: 3, velocity: 1)
        fullScreenImage.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons[Identifiers.backButton]
        waitForElement(backButton)
        backButton.tap()
        
        waitForElement(firstCell)
    }
    
    @MainActor
    func testProfile() throws {
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        waitForElement(profileTab)
        profileTab.tap()
        
        let nameLabel = app.staticTexts[Identifiers.profileName]
        let loginLabel = app.staticTexts[Identifiers.profileLogin]
        waitForElement(nameLabel)
        waitForElement(loginLabel)
        
        XCTAssertEqual(nameLabel.label, TestData.userName)
        XCTAssertEqual(loginLabel.label, TestData.userLogin)
        
        let logoutButton = app.buttons[Identifiers.logoutButton]
        waitForElement(logoutButton)
        logoutButton.tap()
        
        let alert = app.alerts["Пока, пока!"]
        waitForElement(alert)
        alert.scrollViews.otherElements.buttons["Да"].tap()
        
        let authButton = app.buttons[Identifiers.loginButton]
        waitForElement(authButton)
    }
}
