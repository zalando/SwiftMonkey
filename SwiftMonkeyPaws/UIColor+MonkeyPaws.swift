//
//  UIColor+MonkeyPaws.swift
//  SwiftMonkeyPaws
//
//  Created by Daniel.Metzing on 01.02.18.
//

import UIKit

extension UIColor {
    func color(WithBrightness brightness: CGFloat) -> UIColor {
        var H: CGFloat = 0
        var S: CGFloat = 0
        var B: CGFloat = 0
        var A: CGFloat = 0

        guard getHue(&H, saturation: &S, brightness: &B, alpha: &A) else {
            return self
        }

        B += (brightness - 1.0)
        B = max(min(B, 1.0), 0.0)

        return UIColor(hue: H, saturation: S, brightness: B, alpha: A)
    }
}
