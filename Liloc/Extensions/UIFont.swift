//
//  UIFont.swift
//  Liloc
//
//  Created by William Ma on 3/20/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

extension UIFont {

    func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        if let descriptor = fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: 0)
        } else {
            return nil
        }
    }

}
