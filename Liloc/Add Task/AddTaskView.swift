//
//  AddTaskView.swift
//  Liloc
//
//  Created by William Ma on 3/27/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import SwiftUI

struct AddTaskView: View {

    private let controller: AddTaskController

    init(controller: AddTaskController) {
        self.controller = controller
    }

    var body: some View {
        VStack {
            Text("Some weird fish 🦠")
        }.cornerRadius(16)
    }

}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView(controller: AddTaskController())
    }
}
