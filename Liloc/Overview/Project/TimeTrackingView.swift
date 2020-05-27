//
//  TimeTrackingView.swift
//  Liloc
//
//  Created by William Ma on 5/27/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import SwiftUI

struct TimeTrackingView: View {

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .center, spacing: 8) {
                Button(action: {

                }, label: {
                    VStack(alignment: .center, spacing: 0) {
                        Image(systemName: "link.circle")
                        Text("")
                    }
                })
            }
        }
    }

}

struct TimeTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTrackingView()
    }
}
