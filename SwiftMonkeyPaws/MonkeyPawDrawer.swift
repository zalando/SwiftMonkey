//
//  MonkeyPawDrawer.swift
//  SwiftMonkeyPaws
//
//  Created by Daniel.Metzing on 04.02.18.
//

import UIKit

public final class MonkeyPawDrawer {

    public static func monkeyHandPath() -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: -5.91, y: 8.76))
        bezierPath.addCurve(to: CGPoint(x: -10.82, y: 2.15), controlPoint1: CGPoint(x: -9.18, y: 7.11), controlPoint2: CGPoint(x: -8.09, y: 4.9))
        bezierPath.addCurve(to: CGPoint(x: -16.83, y: -1.16), controlPoint1: CGPoint(x: -13.56, y: -0.6), controlPoint2: CGPoint(x: -14.65, y: 0.5))
        bezierPath.addCurve(to: CGPoint(x: -14.65, y: -6.11), controlPoint1: CGPoint(x: -19.02, y: -2.81), controlPoint2: CGPoint(x: -19.57, y: -6.66))
        bezierPath.addCurve(to: CGPoint(x: -8.09, y: -2.81), controlPoint1: CGPoint(x: -9.73, y: -5.56), controlPoint2: CGPoint(x: -8.64, y: -0.05))
        bezierPath.addCurve(to: CGPoint(x: -11.37, y: -13.82), controlPoint1: CGPoint(x: -7.54, y: -5.56), controlPoint2: CGPoint(x: -7, y: -8.32))
        bezierPath.addCurve(to: CGPoint(x: -7.54, y: -17.13), controlPoint1: CGPoint(x: -15.74, y: -19.33), controlPoint2: CGPoint(x: -9.73, y: -20.98))
        bezierPath.addCurve(to: CGPoint(x: -4.27, y: -8.87), controlPoint1: CGPoint(x: -5.36, y: -13.27), controlPoint2: CGPoint(x: -6.45, y: -7.76))
        bezierPath.addCurve(to: CGPoint(x: -4.27, y: -18.23), controlPoint1: CGPoint(x: -2.08, y: -9.97), controlPoint2: CGPoint(x: -3.72, y: -12.72))
        bezierPath.addCurve(to: CGPoint(x: 0.65, y: -18.23), controlPoint1: CGPoint(x: -4.81, y: -23.74), controlPoint2: CGPoint(x: 0.65, y: -25.39))
        bezierPath.addCurve(to: CGPoint(x: 1.2, y: -8.32), controlPoint1: CGPoint(x: 0.65, y: -11.07), controlPoint2: CGPoint(x: -0.74, y: -9.29))
        bezierPath.addCurve(to: CGPoint(x: 3.93, y: -18.78), controlPoint1: CGPoint(x: 2.29, y: -7.76), controlPoint2: CGPoint(x: 3.93, y: -9.3))
        bezierPath.addCurve(to: CGPoint(x: 8.3, y: -16.03), controlPoint1: CGPoint(x: 3.93, y: -23.19), controlPoint2: CGPoint(x: 9.96, y: -21.86))
        bezierPath.addCurve(to: CGPoint(x: 5.57, y: -6.11), controlPoint1: CGPoint(x: 7.76, y: -14.1), controlPoint2: CGPoint(x: 3.93, y: -6.66))
        bezierPath.addCurve(to: CGPoint(x: 9.4, y: -10.52), controlPoint1: CGPoint(x: 7.21, y: -5.56), controlPoint2: CGPoint(x: 9.16, y: -10.09))
        bezierPath.addCurve(to: CGPoint(x: 12.13, y: -6.66), controlPoint1: CGPoint(x: 12.13, y: -15.48), controlPoint2: CGPoint(x: 15.41, y: -9.42))
        bezierPath.addCurve(to: CGPoint(x: 8.3, y: -1.16), controlPoint1: CGPoint(x: 8.85, y: -3.91), controlPoint2: CGPoint(x: 8.85, y: -3.91))
        bezierPath.addCurve(to: CGPoint(x: 8.3, y: 7.11), controlPoint1: CGPoint(x: 7.76, y: 1.6), controlPoint2: CGPoint(x: 9.4, y: 4.35))
        bezierPath.addCurve(to: CGPoint(x: -5.91, y: 8.76), controlPoint1: CGPoint(x: 7.21, y: 9.86), controlPoint2: CGPoint(x: -2.63, y: 10.41))
        bezierPath.close()

        return bezierPath
    }
}
