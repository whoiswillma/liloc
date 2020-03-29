//
//  SettingsBundle.swift
//  Liloc
//
//  Created by William Ma on 3/21/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import SwiftyUserDefaults

enum SettingsBundle {

    static func parseDebug() {
        var shouldReset = false

        if Defaults.settingsLogOut {
            try! KeychainAPI.todoist.delete()
            try! KeychainAPI.toggl.delete()

            Defaults.settingsLogOut = false
            shouldReset = true
        }

        if Defaults.settingsResetCoreData {
            let dao = AppDelegate.shared.dao!

            dao.moc.performAndWait {
                dao.moc.reset()

                for store in dao.psc.persistentStores {
                    try! dao.psc.remove(store)
                    try! FileManager.default.removeItem(at: store.url!)
                }
            }

            Defaults.settingsResetCoreData = false
            shouldReset = true
        }

        if shouldReset {
            fatalError()
        }
    }

}
