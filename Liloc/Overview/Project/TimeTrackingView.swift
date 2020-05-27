//
//  TimeTrackingView.swift
//  Liloc
//
//  Created by William Ma on 5/27/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import SwiftUI

struct TimeTrackingView: View {

    enum Mode: Equatable {
        case notLinked
        case linked(name: String, timeToday: String)
    }

    @State var mode: Mode

    let linkButtonPressed: () -> Void

    var body: some View {
        GeometryReader { container in
            ScrollView(.horizontal) {
                HStack(alignment: .center, spacing: 8) {
                    Button(action: {
                        self.linkButtonPressed()
                    }, label: {
                        VStack(alignment: .center, spacing: 0) {
                            Image(systemName: "link.circle")
                                .resizable()
                                .frame(width: 32, height: 32)
                            self.linkText.layoutPriority(1)
                        }
                    })
                    .padding(8)
                    .frame(width: container.size.width / 4)

                    Button(action: {

                    }, label: {
                        VStack(alignment: .center, spacing: 0) {
                            Image(systemName: "clock")
                                .resizable()
                                .frame(width: 32, height: 32)
                            self.timeTodayText
                        }
                    })
                    .padding(8)
                    .frame(width: container.size.width / 4)
                }
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(16)
            }
        }
    }

    private var linkText: Text {
        switch mode {
        case .notLinked: return Text("Link Toggl")
        case let .linked(name: name, _): return Text(name)
        }
    }

    private var timeTodayText: Text {
        switch mode {
        case .notLinked: return Text("-- hr")
        case let .linked(name: _, timeToday: timeToday): return Text(timeToday)
        }
    }

}

struct TimeTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        TimeTrackingView(mode: .notLinked, linkButtonPressed: {})
    }
}
