//
//  MonkeyPaws.swift
//  Fleek
//
//  Created by Dag Agren on 12/04/16.
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit

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

    public typealias BezierPathDrawer = () -> UIBezierPath

    private var gestures: [(hash: Int?, gesture: Gesture)] = []
    private weak var view: UIView?

    let configuration: Configuration
    let bezierPathDrawer: BezierPathDrawer
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
        - parameter configuration: Configure the visual appearance
          of the Monkey paws. By default it uses the built in visual
          parameters.
        - parameter bezierPathDrawer: Create your own visualisation by
          defining a bezier path drawer closure
    */
    public init(view: UIView,
                tapUIApplication: Bool = true,
                configuration: Configuration = Configuration(),
                bezierPathDrawer: @escaping BezierPathDrawer = MonkeyPawDrawer.monkeyHandPath) {
        self.configuration = configuration
        self.bezierPathDrawer = bezierPathDrawer
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
            if gestures.count > configuration.paws.maxShown {
                gestures.removeFirst()
            }

            gestures.append((hash: touchHash, gesture: Gesture(from: point, inLayer: layer, configuration: configuration, bezierPathDrawer: bezierPathDrawer)))

            for i in 0 ..< gestures.count {
                let number = gestures.count - i
                let gesture = gestures[i].gesture
                gesture.number = number
            }
        }
    }

    private static let swizzleMethods: Bool = {
        let originalSelector = #selector(UIApplication.sendEvent(_:))
        let swizzledSelector = #selector(UIApplication.monkey_sendEvent(_:))
        
        let originalMethod = class_getInstanceMethod(UIApplication.self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(UIApplication.self, swizzledSelector)
        
        let didAddMethod = class_addMethod(UIApplication.self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(UIApplication.self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
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

    let configuration: Configuration

    private static var counter: Int = 0

    init(from: CGPoint, inLayer: CALayer, configuration: Configuration, bezierPathDrawer: @escaping MonkeyPaws.BezierPathDrawer) {
        self.points = [from]
        self.configuration = configuration

        let counter = Gesture.counter
        Gesture.counter += 1

        let colour: UIColor = pawsColor(configuration: configuration.paws, seed: counter)

        startLayer.path = customize(path: bezierPathDrawer(), seed: counter).cgPath

        startLayer.strokeColor = colour.cgColor
        startLayer.fillColor = nil
        startLayer.position = from
        containerLayer.addSublayer(startLayer)

        numberLayer.string = "1"
        numberLayer.bounds = CGRect(x:0, y: 0, width: 32, height: 13)
        numberLayer.fontSize = 10
        numberLayer.alignmentMode = CATextLayerAlignmentMode.center
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

            let fraction = Float(number - 1) / Float(configuration.paws.maxShown)
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
            newLayer.strokeColor = self.startLayer.strokeColor
            newLayer.fillColor = nil

            let maskPath = CGMutablePath()
            maskPath.addRect(CGRect(x: -10000, y: -10000, width: 20000, height: 20000))
            maskPath.addPath(startPath)

            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
            maskLayer.position = self.startLayer.position
            newLayer.mask = maskLayer

            self.pathLayer = newLayer
            self.containerLayer.addSublayer(newLayer)

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

        let path = circlePath(radius: configuration.radius.circle)
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

        let path = crossPath(radius: configuration.radius.cross)
        layer.path = path.cgPath

        containerLayer.addSublayer(layer)
        endLayer = layer
    }

    func pawsColor(configuration: Configuration.Paws, seed: Int) -> UIColor {
        switch configuration.color {
        case .randomized:
            return UIColor(hue: CGFloat(fmod(Float(seed) * 0.391, 1)),
                           saturation: 1,
                           brightness: configuration.brightness,
                           alpha: 1)
        case .constant(let constantColour):
            return constantColour.color(WithBrightness: configuration.brightness)
        }
    }
}

private func customize(path: UIBezierPath, seed: Int) -> UIBezierPath {

    let angle = 45 * (CGFloat(fmod(Float(seed) * 0.279, 1)) * 2 - 1)
    let mirrored = seed % 2 == 0

    if mirrored {
        path.apply(CGAffineTransform(scaleX: -1, y: 1))
    }

    path.apply(CGAffineTransform(rotationAngle: angle / 180 * CGFloat.pi))

    return path
}

private func circlePath(radius: CGFloat) -> UIBezierPath {
    return UIBezierPath(ovalIn: CGRect(centre: CGPoint.zero, size: CGSize(width: radius * 2, height: radius * 2)))
}

private func crossPath(radius: CGFloat) -> UIBezierPath {
    let rect = CGRect(centre: CGPoint.zero, size: CGSize(width: radius * 2, height: radius * 2))
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
    @objc func monkey_sendEvent(_ event: UIEvent) {
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
        self.init(origin: CGPoint(x: centre.x - size.width / 2, y: centre.y - size.height / 2),
                  size: size)
    }
}
