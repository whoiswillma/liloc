//
//  ServiceSignInView.swift
//  Liloc
//
//  Created by William Ma on 3/19/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import SwiftUI

enum Service: String {

    case todoist = "Todoist"
    case toggl = "Toggl"

    var image: Image {
        return Image(rawValue)
    }

    var title: String {
        return rawValue
    }

}

struct ServiceSignInView: View {

    private enum Const {
        static let checkmarkSize: CGFloat = 22
    }

    @Binding var signedIn: Bool

    private let service: Service

    private let action: () -> Void

    init(service: Service, signedIn: Binding<Bool>, action: @escaping () -> Void) {
        self._signedIn = signedIn
        self.service = service
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Spacer()
                .frame(width: Const.checkmarkSize, height: Const.checkmarkSize)
                .padding()

            Spacer()

            VStack {
                service.image
                    .interpolation(.high)
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .frame(height: 88)

                Text("Log in to " + service.title)
                    .foregroundColor(Color.gray)
            }.frame(alignment: .leading)

            Spacer()

            Image(systemName: signedIn ? "checkmark.circle" : "circle")
                .resizable()
                .frame(width: Const.checkmarkSize, height: Const.checkmarkSize)
                .padding()
        }
        .disabled(signedIn)
    }
}

struct ServiceSignInView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ServiceSignInView(service: .todoist, signedIn: .constant(true), action: {})
            ServiceSignInView(service: .toggl, signedIn: .constant(false), action: {})
        }
    }
}
