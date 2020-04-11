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

    static func fromTodoistId(_ id: Int64) -> UIColor {
        switch id {
        case 30: return UIColor(hex: "b8256f")
        case 31: return UIColor(hex: "db4035")
        case 32: return UIColor(hex: "ff9933")
        case 33: return UIColor(hex: "fad000")
        case 34: return UIColor(hex: "afb83b")
        case 35: return UIColor(hex: "7ecc49")
        case 36: return UIColor(hex: "299438")
        case 37: return UIColor(hex: "6accbc")
        case 38: return UIColor(hex: "158fad")
        case 39: return UIColor(hex: "14aaf5")
        case 40: return UIColor(hex: "96c3eb")
        case 41: return UIColor(hex: "4073ff")
        case 42: return UIColor(hex: "884dff")
        case 43: return UIColor(hex: "af38eb")
        case 44: return UIColor(hex: "eb96eb")
        case 45: return UIColor(hex: "e60194")
        case 46: return UIColor(hex: "ff8d85")
        case 47: return UIColor(hex: "808080")
        case 48: return UIColor(hex: "b8b8b8")
        case 49: return UIColor(hex: "ccac93")
        default: return UIColor(hex: "808080")
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

    func darken() -> UIColor {
        adjustBrightness(constant: 0.15).adjustSaturation(constant: -0.15)
    }

}
