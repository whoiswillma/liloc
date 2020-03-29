//
//  OnboardingViewController.swift
//  Liloc
//
//  Created by William Ma on 3/19/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import OAuthSwift
import SwiftUI
import UIKit

class OnboardingController: LLContainerController<UIHostingController<OnboardingView>>, ObservableObject {

    @Published var todoistSignedIn: Bool = false
    @Published var togglSignedIn: Bool = false

    init() {
        super.init(nibName: nil, bundle: nil)

        child = UIHostingController(rootView: OnboardingView(controller: self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var todoistAuth: OAuth2Swift?

    override func viewDidLoad() {
        super.viewDidLoad()

        checkWhetherServicesSignedIn()
    }

    func todoistSignIn() {
        let auth = OAuth2Swift(
            consumerKey: "2e6675590981498d83a831fc15ab46a6",
            consumerSecret: "c6d2ff42e46a418f96b2a641b4e59665",
            authorizeUrl: "https://todoist.com/oauth/authorize",
            accessTokenUrl: "https://todoist.com/oauth/access_token",
            responseType: "code"
        )
        todoistAuth = auth

        auth.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: auth)

        let state = generateState(withLength: 20)
        auth.authorize(
            withCallbackURL: "liloc://oauth-callback",
            scope: "data:read_write",
            state: state
        ) { result in
            switch result {
            case let .success((credentials, _, _)):
                try! KeychainAPI.todoist.set(credentials.oauthToken)
                self.todoistSignedIn = true

            case let .failure(error):
                fatalError(error.localizedDescription)
                break
            }
        }
    }

    func togglSignIn() {
        let controller = TogglSignInController()
        controller.authenticationCallback = { username, password in
            try! KeychainAPI.toggl.set((account: username, password: password))

            self.navigationController?.popToViewController(self, animated: true)
            self.togglSignedIn = true
        }
        navigationController?.pushViewController(controller, animated: true)
    }

    private func checkWhetherServicesSignedIn() {
        todoistSignedIn = try! KeychainAPI.todoist.fetch() != nil
        togglSignedIn = try! KeychainAPI.toggl.fetch() != nil
    }

}
