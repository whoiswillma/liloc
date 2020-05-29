//
//  UIColor.swift
//  Liloc
//
//  Created by William Ma on 3/26/20.
//  Copyright © 2020 William Ma. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init(hex: String) {
        let value = UInt32(hex, radix: 16)!
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: 1)
    }

    convenience init(todoistId id: Int64) {
        switch id {
        case 30: self.init(hex: "b8256f")
        case 31: self.init(hex: "db4035")
        case 32: self.init(hex: "ff9933")
        case 33: self.init(hex: "fad000")
        case 34: self.init(hex: "afb83b")
        case 35: self.init(hex: "7ecc49")
        case 36: self.init(hex: "299438")
        case 37: self.init(hex: "6accbc")
        case 38: self.init(hex: "158fad")
        case 39: self.init(hex: "14aaf5")
        case 40: self.init(hex: "96c3eb")
        case 41: self.init(hex: "4073ff")
        case 42: self.init(hex: "884dff")
        case 43: self.init(hex: "af38eb")
        case 44: self.init(hex: "eb96eb")
        case 45: self.init(hex: "e60194")
        case 46: self.init(hex: "ff8d85")
        case 47: self.init(hex: "808080")
        case 48: self.init(hex: "b8b8b8")
        case 49: self.init(hex: "ccac93")
        default: self.init(hex: "808080")
        }
    }

    func adjustSaturation(factor: CGFloat = 1, constant: CGFloat = 0) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: max(0, min(1, factor * s + constant)), brightness: b, alpha: a)
    }

    func adjustBrightness(factor: CGFloat = 1, constant: CGFloat = 0) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: max(0, min(1, factor * b + constant)), alpha: a)
    }

    func lighten() -> UIColor {
        adjustBrightness(constant: 0.15).adjustSaturation(constant: -0.15)
    }

    func darken() -> UIColor {
        adjustBrightness(constant: -0.15)
    }

}
