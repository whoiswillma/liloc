//
//  LLLayerShadowManager.swift
//  Liloc
//
//  Created by William Ma on 6/20/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import UIKit

class LLLayerShadowManager {

    struct ShadowMasks: OptionSet {

        typealias RawValue = UInt

        static let top = ShadowMasks(rawValue: 1 << 1)
        static let left = ShadowMasks(rawValue: 1 << 2)
        static let right = ShadowMasks(rawValue: 1 << 3)
        static let bottom = ShadowMasks(rawValue: 1 << 4)
        
        let rawValue: UInt

        init(rawValue: UInt) {
            self.rawValue = rawValue
        }

    }

    // This value is approximated by eye. The only requirement of this constant
    // is that it be greater than or equal to the actual shadow "width" so 
    // the mask can fill the actual shadow
    static let layerDefaultShadowWidth: CGFloat = 8

    private(set) weak var layer: CALayer?

    /**
     The portions of the layer's shadow that are visible.

     When `shadowMask` is nil, a nil mask is set on the layer.

     When `shadowMask` is non-nil, a mask is set on the layer that enables the
     specified portions of the layer's shadow to be displayed.

     To maintain a layer's mask, whenever the layer's geometry changes, either
     - update the shadow manager's `shadowMask` property, or
     - call `layerGeometryDidChange`
     */
    var shadowMask: ShadowMasks? = nil {
        didSet {
            setLayerMaskFromShadowMask()
        }
    }

    init(layer: CALayer) {
        self.layer = layer
    }

    func setDefaultShadowProperties() {
        layer?.shadowColor = UIColor.black.cgColor
        layer?.shadowOpacity = 0.33
        layer?.shadowOffset = .zero
    }

    /**
     Call this function to maintain the layer's mask while the `shadowMask`
     property is non-nil.
     */
    func layerGeometryDidChange() {
        setLayerMaskFromShadowMask()
    }

    private func setLayerMaskFromShadowMask() {
        guard let layer = layer else {
            return
        }

        guard let shadowMask = shadowMask else {
            layer.mask = nil
            return
        }

        let mask = CALayer()
        mask.backgroundColor = UIColor.black.cgColor
        mask.frame = layer.bounds.inset(by:
            UIEdgeInsets(top: shadowMask.contains(.top) ? -LLLayerShadowManager.layerDefaultShadowWidth : 0,
                         left: shadowMask.contains(.left) ? -LLLayerShadowManager.layerDefaultShadowWidth : 0,
                         bottom: shadowMask.contains(.bottom) ? -LLLayerShadowManager.layerDefaultShadowWidth : 0,
                         right: shadowMask.contains(.right) ? -LLLayerShadowManager.layerDefaultShadowWidth : 0))
        layer.mask = mask
    }

}
