//
//  UIColorExtension.swift
//  ControlHealth
//
//  Created by alpha on 27/01/2018.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import UIKit

public extension UIColor {
    // MARK: - RGB

    public static func rgb(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> UIColor {
        let r = CGFloat(r)
        let g = CGFloat(g)
        let b = CGFloat(b)
        let divider: CGFloat = 255

        return UIColor(red: r / divider, green: g / divider, blue: b / divider, alpha: a)
    }

    @available(iOS 10.0, *)
    static func rgbP3(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1) -> UIColor {
        let r = CGFloat(r)
        let g = CGFloat(g)
        let b = CGFloat(b)
        let divider: CGFloat = 255

        return UIColor(displayP3Red: r / divider, green: g / divider, blue: b / divider, alpha: a)
    }

    // MARK: - HEX

    public static func hex(_ hex: Int, _ a: CGFloat = 1) -> UIColor {
        let r = (hex >> 16) & 0xFF
        let g = (hex >> 8) & 0xFF
        let b = (hex >> 0) & 0xFF

        return UIColor.rgb(r, g, b, a)
    }

    public static func hex(_ string: String, _ a: CGFloat = 1) -> UIColor {
        let hex = Int(string, radix: 16) ?? 0

        let r = (hex >> 16) & 0xFF
        let g = (hex >> 8) & 0xFF
        let b = (hex >> 0) & 0xFF

        return UIColor.rgb(r, g, b, a)
    }

    @available(iOS 10.0, *)
    public static func hexP3(_ hex: Int, _ a: CGFloat = 1) -> UIColor {
        let r = (hex >> 16) & 0xFF
        let g = (hex >> 8) & 0xFF
        let b = (hex >> 0) & 0xFF

        return UIColor.rgbP3(r, g, b, a)
    }

    @available(iOS 10.0, *)
    public static func hexP3(_ string: String, _ a: CGFloat = 1) -> UIColor {
        let hex = Int(string, radix: 16) ?? 0

        let r = (hex >> 16) & 0xFF
        let g = (hex >> 8) & 0xFF
        let b = (hex >> 0) & 0xFF

        return UIColor.rgbP3(r, g, b, a)
    }
}
