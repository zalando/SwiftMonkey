//
//  MonkeyPaws.swift
//  Fleek
//
//  Created by Dag Agren on 12/04/16.
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit

private let maxGesturesShown: Int = 15
private let crossRadius: CGFloat = 7
private let circleRadius: CGFloat = 7

/**
    A class that visualises input events as an overlay over
    your regular UI. To use, simply instantiate it and
    keep a reference to it around so that it does not get
    deinited.

    You will want to have some way to only instantiate it
    for test usage, though, such as adding a command-line
    flag to enable it.

    Example usage:

    ```
    var paws: MonkeyPaws?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if CommandLine.arguments.contains("--MonkeyPaws") {
            paws = MonkeyPaws(view: window!)
        }
        return true
    }
    ```
*/
public class MonkeyPaws: NSObject, CALayerDelegate {
    private var gestures: [(hash: Int?, gesture: Gesture)] = []
    private weak var view: UIView?

    let layer = CALayer()

    fileprivate static var tappingTracks: [WeakReference<MonkeyPaws>] = []

    /**
        Create a MonkeyPaws object that will visualise input
        events.

        - parameter view: The view to put the visualisation
          layer in. Usually, you will want to pass your main
          `UIWindow` here.
        - parameter tapUIApplication: By default, MonkeyPaws
          will swizzle some methods in UIApplication to
          intercept events so that it can visualise them.
          If you do not want this, pass `false` here and
          provide it with events manually.
    */
    public init(view: UIView, tapUIApplication: Bool = true) {
        super.init()
        self.view = view

        layer.delegate = self
        layer.isOpaque = false
        layer.frame = view.layer.bounds
        layer.contentsScale = UIScreen.main.scale
        layer.rasterizationScale = UIScreen.main.scale

        view.layer.addSublayer(layer)

        if tapUIApplication {
            tapUIApplicationSendEvent()
        }
    }

    /**
        If you have disabled UIApplication event tapping,
        use this method to pass in `UIEvent` objects to
        visualise.
    */
    public func append(event: UIEvent) {
        guard event.type == .touches else { return }
        guard let touches = event.allTouches else { return }

        for touch in touches {
            append(touch: touch)
        }

        bumpAndDisplayLayer()
    }

    func append(touch: UITouch) {
        guard let view = view else { return }

        let touchHash = touch.hash
        let point = touch.location(in: view)

        let index = gestures.index(where: { (gestureHash, _) -> Bool in
            return gestureHash == touchHash
        })

        if let index = index {
            let gesture = gestures[index].gesture

            if touch.phase == .ended {
                gestures[index].gesture.end(at: point)
                gestures[index].hash = nil
            } else if touch.phase == .cancelled {
                gestures[index].gesture.cancel(at: point)
                gestures[index].hash = nil
            } else {
                gesture.extend(to: point)
            }
        } else {
            if gestures.count > maxGesturesShown {
                gestures.removeFirst()
            }

            gestures.append((hash: touchHash, gesture: Gesture(from: point, inLayer: layer)))

            for i in 0 ..< gestures.count {
                gestures[i].gesture.number = gestures.count - i
            }
        }
    }

    private static let swizzleMethods: Bool = {
        let originalSelector = #selector(UIApplication.sendEvent(_:))
        let swizzledSelector = #selector(UIApplication.monkey_sendEvent(_:))
        
        let originalMethod = class_getInstanceMethod(UIApplication.self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(UIApplication.self, swizzledSelector)
        
        let didAddMethod = class_addMethod(UIApplication.self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(UIApplication.self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }

        return true
    }()
    
    private func tapUIApplicationSendEvent() {
        _ = MonkeyPaws.swizzleMethods
        MonkeyPaws.tappingTracks.append(WeakReference(self))
    }

    private func bumpAndDisplayLayer() {
        guard let superlayer = layer.superlayer else { return }
        guard let layers = superlayer.sublayers else { return }
        guard let index = layers.index(of: layer) else { return }

        if index != layers.count - 1 {
            layer.removeFromSuperlayer()
            superlayer.addSublayer(layer)
        }

        layer.frame = superlayer.bounds

        layer.setNeedsDisplay()
        layer.displayIfNeeded()
    }
}

private class Gesture {
    var points: [CGPoint]

    var containerLayer = CALayer()
    var startLayer = CAShapeLayer()
    var numberLayer = CATextLayer()
    var pathLayer: CAShapeLayer?
    var endLayer: CAShapeLayer?

    private static var counter: Int = 0

    init(from: CGPoint, inLayer: CALayer) {
        self.points = [from]

        let counter = Gesture.counter
        Gesture.counter += 1

        let angle = 45 * (CGFloat(fmod(Float(counter) * 0.279, 1)) * 2 - 1)
        let mirrored = counter % 2 == 0
        let colour = UIColor(hue: CGFloat(fmod(Float(counter) * 0.391, 1)), saturation: 1, brightness: 0.5, alpha: 1)
        startLayer.path = monkeyHandPath(angle: angle, scale: 1, mirrored: mirrored).cgPath
        startLayer.strokeColor = colour.cgColor
        startLayer.fillColor = nil
        startLayer.position = from
        containerLayer.addSublayer(startLayer)

        numberLayer.string = "1"
        numberLayer.bounds = CGRect(x:0, y: 0, width: 32, height: 13)
        numberLayer.fontSize = 10
        numberLayer.alignmentMode = kCAAlignmentCenter
        numberLayer.foregroundColor = colour.cgColor
        numberLayer.position = from
        numberLayer.contentsScale = UIScreen.main.scale
        containerLayer.addSublayer(numberLayer)

        inLayer.addSublayer(containerLayer)
    }

    deinit {
        containerLayer.removeFromSuperlayer()
    }


    var number: Int = 0 {
        didSet {
            numberLayer.string = String(number)

            let fraction = Float(number - 1) / Float(maxGesturesShown)
            let alpha = sqrt(1 - fraction)
            containerLayer.opacity = alpha
        }
    }

    func extend(to: CGPoint) {
        guard let startPath = startLayer.path,
        let startPoint = points.first else {
            assertionFailure("No start marker layer exists")
            return
        }

        points.append(to)

        let pathLayer = self.pathLayer ?? { () -> CAShapeLayer in
            let newLayer = CAShapeLayer()
            newLayer.strokeColor = startLayer.strokeColor
            newLayer.fillColor = nil

            let maskPath = CGMutablePath()
            maskPath.addRect(CGRect(x: -10000, y: -10000, width: 20000, height: 20000))
            maskPath.addPath(startPath)

            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath
            maskLayer.fillRule = kCAFillRuleEvenOdd
            maskLayer.position = startLayer.position
            newLayer.mask = maskLayer

            self.pathLayer = newLayer
            containerLayer.addSublayer(newLayer)

            return newLayer
        }()

        let path = CGMutablePath()
        path.move(to: startPoint)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }

        pathLayer.path = path
    }

    func end(at: CGPoint) {
        guard endLayer == nil else {
            assertionFailure("Attempted to end or cancel a gesture twice!")
            return
        }

        extend(to: at)

        let layer = CAShapeLayer()
        layer.strokeColor = startLayer.strokeColor
        layer.fillColor = nil
        layer.position = at

        let path = circlePath()
        layer.path = path.cgPath

        containerLayer.addSublayer(layer)
        endLayer = layer
    }

    func cancel(at: CGPoint) {
        guard endLayer == nil else {
            assertionFailure("Attempted to end or cancel a gesture twice!")
            return
        }

        extend(to: at)

        let layer = CAShapeLayer()
        layer.strokeColor = startLayer.strokeColor
        layer.fillColor = nil
        layer.position = at

        let path = crossPath()
        layer.path = path.cgPath

        containerLayer.addSublayer(layer)
        endLayer = layer
    }
}

private func monkeyHandPath(angle: CGFloat, scale: CGFloat, mirrored: Bool) -> UIBezierPath {
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

    bezierPath.apply(CGAffineTransform(translationX: 0.5, y: 0))

    bezierPath.apply(CGAffineTransform(scaleX: scale, y: scale))

    if mirrored {
        bezierPath.apply(CGAffineTransform(scaleX: -1, y: 1))
    }

    bezierPath.apply(CGAffineTransform(rotationAngle: angle / 180 * CGFloat.pi))

    return bezierPath
}

private func circlePath() -> UIBezierPath {
    return UIBezierPath(ovalIn: CGRect(centre: CGPoint.zero, size: CGSize(width: circleRadius * 2, height: circleRadius * 2)))
}

private func crossPath() -> UIBezierPath {
    let rect = CGRect(centre: CGPoint.zero, size: CGSize(width: crossRadius * 2, height: crossRadius * 2))
    let cross = UIBezierPath()
    cross.move(to: CGPoint(x: rect.minX, y: rect.minY))
    cross.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    cross.move(to: CGPoint(x: rect.minX, y: rect.maxY))
    cross.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    return cross
}

private struct WeakReference<T: AnyObject> {
    weak var value: T?
    init(_ value: T) { self.value = value }
}

extension UIApplication {
    func monkey_sendEvent(_ event: UIEvent) {
        for weakTrack in MonkeyPaws.tappingTracks {
            if let track = weakTrack.value {
                track.append(event: event)
            }
        }

        self.monkey_sendEvent(event)
    }
}

extension CGRect {
    public init(centre: CGPoint, size: CGSize) {
        self.origin = CGPoint(x: centre.x - size.width / 2, y: centre.y - size.height / 2)
        self.size = size
    }
}
