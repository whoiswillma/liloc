//
//  DefaultsKeys.swift
//  Liloc
//
//  Created by William Ma on 3/20/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import SwiftyUserDefaults

extension DefaultsKeys {

    var settingsLogOut: DefaultsKey<Bool> {
        .init("settingsLogOutOnLaunch", defaultValue: false)
    }
    var settingsResetCoreData: DefaultsKey<Bool>{
        .init("settingsResetCoreDataOnLaunch", defaultValue: false)
    }

}
