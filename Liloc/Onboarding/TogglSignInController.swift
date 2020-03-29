//
//  TogglSignInController.swift
//  Liloc
//
//  Created by William Ma on 3/19/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import Alamofire
import SnapKit
import SwiftUI
import UIKit

class TogglSignInController: UIViewController {

    private enum Const {
        static let switchToAPIKey = "Use API key instead"
        static let switchToUsernamePassword = "Use email and password instead"
    }

    private enum SignInMethod: Int, CaseIterable {
        case usernamePassword
        case apiKey
    }

    private var scrollView: UIScrollView!

    private var titleLabel: UILabel!

    private var emailPasswordView: UIStackView!
    private var emailTextField: UITextField!
    private var passwordTextField: UITextField!

    private var apiKeyView: UIStackView!
    private var apiKeyTextField: UITextField!

    private var signInMethod: SignInMethod = .usernamePassword
    private var signInView: UIView!

    private var toggleSignInMethodButton: UIButton!

    private var signInButton: UIButton!

    var authenticationCallback: ((_ username: String, _ password: String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        setUpScrollView()
        setUpSignInButton()
        setUpTitleLabel()
        setUpEmailPasswordView()
        setUpApiKeyView()
        setUpSignInView()
        setUpToggleSignInMethodButton()
    }

    @objc private func toggleSignInMethodButtonPressed(_ sender: UIButton) {
        let newSignInMethod: SignInMethod
        switch signInMethod {
        case .apiKey: newSignInMethod = .usernamePassword
        case .usernamePassword: newSignInMethod = .apiKey
        }
        signInMethod = newSignInMethod

        switch signInMethod {
        case .apiKey:
            toggleSignInMethodButton.setTitle(Const.switchToUsernamePassword, for: .normal)
            apiKeyView.alpha = 1
            emailPasswordView.alpha = 0

        case .usernamePassword:
            toggleSignInMethodButton.setTitle(Const.switchToAPIKey, for: .normal)
            apiKeyView.alpha = 0
            emailPasswordView.alpha = 1

        }

        updateSignInButtonEnabled()
        view.endEditing(true)
    }

    private func updateSignInButtonEnabled() {
        let disabled: Bool
        switch signInMethod {
        case .apiKey:
            disabled = apiKeyTextField.text?.isEmpty ?? false
        case .usernamePassword:
            disabled = emailTextField.text?.isEmpty ?? false
                || passwordTextField.text?.isEmpty ?? false
        }

        signInButton.isEnabled = !disabled
        signInButton.backgroundColor = disabled ? .systemGray : UIColor(named: "LilocBlue")
    }

    @objc private func signInButtonPressed(_ sender: UIButton) {
        signInIfPossible()
    }

    private func signInIfPossible() {
        guard signInButton.isEnabled else {
            return
        }

        let username: String
        let password: String
        switch signInMethod {
        case .apiKey:
            username = apiKeyTextField.text ?? ""
            password = "api_key"
        case .usernamePassword:
            username = emailTextField.text ?? ""
            password = passwordTextField.text ?? ""
        }

        let headers: HTTPHeaders = [
            .authorization(username: username, password: password)
        ]

        AF.request(
            "https://www.toggl.com/api/v8/me",
            headers: headers
        ).responseJSON { response in
            guard let statusCode = response.response?.statusCode else {
                return
            }

            switch statusCode {
            case 200:
                self.authenticationCallback?(username, password)

            case 403:
                break

            default:
                break
            }
        }
    }

}

extension TogglSignInController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSignInButtonEnabled()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()

        case passwordTextField:
            passwordTextField.resignFirstResponder()
            signInIfPossible()

        case apiKeyTextField:
            apiKeyTextField.resignFirstResponder()
            signInIfPossible()

        default:
            break
        }

        return true
    }

}

extension TogglSignInController {

    private func setUpView() {
        view.backgroundColor = .systemBackground
    }

    private func setUpScrollView() {
        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }

    private func setUpSignInButton() {
        signInButton = UIButton(type: .system)
        signInButton.setTitle("Log In", for: .normal)
        signInButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        signInButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.backgroundColor = .systemGray
        signInButton.clipsToBounds = true
        signInButton.layer.cornerRadius = 16
        signInButton.addTarget(
            self,
            action: #selector(signInButtonPressed(_:)),
            for: .touchUpInside
        )

        view.addSubview(signInButton)
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.snp.bottomMargin).inset(16)
        }
    }

    private func setUpTitleLabel() {
        let topMargin = UIView()
        scrollView.addSubview(topMargin)
        topMargin.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(view).dividedBy(12).offset(16)
        }

        titleLabel = UILabel()
        titleLabel.text = "Log in to Toggl"
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textAlignment = .center
        scrollView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(topMargin.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    private func setUpEmailPasswordView() {
        emailPasswordView = UIStackView()
        emailPasswordView.axis = .vertical
        emailPasswordView.spacing = 12
        emailPasswordView.isLayoutMarginsRelativeArrangement = true
        emailPasswordView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let emailLabel = UILabel()
        emailLabel.text = "Email"
        emailLabel.font = .preferredFont(forTextStyle: .headline)
        emailPasswordView.addArrangedSubview(emailLabel)

        emailTextField = UITextField()
        emailTextField.placeholder = "abc@xyz.com"
        emailTextField.keyboardType = .emailAddress
        emailTextField.delegate = self
        emailPasswordView.addArrangedSubview(emailTextField)

        emailPasswordView.addArrangedSubview(UIHDivider())

        let passwordLabel = UILabel()
        passwordLabel.text = "Password"
        passwordLabel.font = .preferredFont(forTextStyle: .headline)
        emailPasswordView.addArrangedSubview(passwordLabel)

        passwordTextField = UITextField()
        passwordTextField.placeholder = "password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        emailPasswordView.addArrangedSubview(passwordTextField)

        emailPasswordView.addArrangedSubview(UIHDivider())
    }

    private func setUpApiKeyView() {
        apiKeyView = UIStackView()
        apiKeyView.axis = .vertical
        apiKeyView.spacing = 12
        apiKeyView.isLayoutMarginsRelativeArrangement = true
        apiKeyView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let apiKeyLabel = UILabel()
        apiKeyLabel.text = "API Key"
        apiKeyLabel.font = .preferredFont(forTextStyle: .headline)
        apiKeyView.addArrangedSubview(apiKeyLabel)

        apiKeyTextField = UITextField()
        apiKeyTextField.placeholder = "1971800d4d82861d8f2c1651fea4d212"
        apiKeyTextField.delegate = self
        apiKeyView.addArrangedSubview(apiKeyTextField)

        apiKeyView.addArrangedSubview(UIHDivider())
    }

    private func setUpSignInView() {
        signInView = UIView()
        scrollView.addSubview(signInView)
        signInView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(44)
            make.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
        }

        signInView.addSubview(emailPasswordView)
        emailPasswordView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview().priority(.low)
        }

        signInView.addSubview(apiKeyView)
        apiKeyView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview().priority(.low)
        }

        emailPasswordView.alpha = 1
        apiKeyView.alpha = 0
    }

    private func setUpToggleSignInMethodButton() {
        toggleSignInMethodButton = UIButton(type: .system)
        toggleSignInMethodButton.setTitle(Const.switchToAPIKey, for: .normal)
        toggleSignInMethodButton.addTarget(
            self,
            action: #selector(toggleSignInMethodButtonPressed(_:)),
            for: .touchUpInside
        )
        scrollView.addSubview(toggleSignInMethodButton)

        toggleSignInMethodButton.snp.makeConstraints { make in
            make.top.equalTo(signInView.snp.bottom).offset(44)
            make.leading.trailing.equalToSuperview()
        }
    }

}
