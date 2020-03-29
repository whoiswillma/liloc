//
//  OnboardingView.swift
//  Liloc
//
//  Created by William Ma on 3/19/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import OAuthSwift
import SwiftUI

struct OnboardingView: View {

    @ObservedObject var controller: OnboardingController

    private var signedIn: Bool {
        return controller.todoistSignedIn && controller.togglSignedIn
    }

    var body: some View {
        VStack {
            Spacer()

            Text("Liloc relies on these services to manage your tasks and track your time.")
                .font(.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .padding()

            Spacer()

            ServiceSignInView(service: .todoist, signedIn: $controller.todoistSignedIn) {
                self.controller.todoistSignIn()
            }
            .padding()

            Divider()
                .padding()

            ServiceSignInView(service: .toggl, signedIn: $controller.togglSignedIn) {
                self.controller.togglSignIn()
            }
            .padding()
            
            Spacer()

            Button(action: {
                self.controller.dismiss(animated: true)
            }) {
                HStack {
                    Spacer()
                    Text("Done")
                        .fontWeight(.bold)
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .padding()
                    Spacer()
                }
                .background(signedIn ? Color("LilocBlue") : .gray)
                .cornerRadius(16)
            }
            .padding()
            .disabled(!signedIn)
        }
        .accentColor(Color("LilocBlue"))
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(controller: OnboardingController())
    }
}
