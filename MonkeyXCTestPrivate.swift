//
//  MonkeyXCTestPrivate.swift
//  Fleek
//
//  Created by Dag Agren on 04/04/16.
//  Copyright © 2016 Zalando SE. All rights reserved.
//
//  Event generation using private XCTest classes.
//

import UIKit
import XCTest

var orientationValue: UIDeviceOrientation = .portrait

extension Monkey {
    var sharedXCEventGenerator: XCEventGenerator {
        let generatorClass = unsafeBitCast(NSClassFromString("XCEventGenerator"),to: XCEventGenerator.Type.self)
        return generatorClass.sharedGenerator()
    }

    public func addXCTestTapAction(weight: Double, multipleTapProbability: Double = 0.05,
    multipleTouchProbability: Double = 0.05) {
        addAction(weight: weight) { [weak self] in
            let numberOfTaps: UInt
            if self!.r.randomDouble() < multipleTapProbability {
                numberOfTaps = UInt(self!.r.randomUInt32() % 2) + 2
            } else {
                numberOfTaps = 1
            }

            let locations: [CGPoint]
            if self!.r.randomDouble() < multipleTouchProbability {
                let numberOfTouches = Int(self!.r.randomUInt32() % 3) + 2
                let rect = self!.randomRect()
                locations = (1...numberOfTouches).map { _ in
                    self!.randomPoint(inRect: rect)
                }
            } else {
                locations = [ self!.randomPoint() ]
            }

            let semaphore = DispatchSemaphore(value: 0)
            self!.sharedXCEventGenerator.tapAtTouchLocations(locations, numberOfTaps: numberOfTaps, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    public func addXCTestLongPressAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let point = self!.randomPoint()
            let semaphore = DispatchSemaphore(value: 0)
            self!.sharedXCEventGenerator.pressAtPoint(point, forDuration: 0.5, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    public func addXCTestDragAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let start = self!.randomPoint()
            let end = self!.randomPoint()

            let semaphore = DispatchSemaphore(value: 0)
            self!.sharedXCEventGenerator.pressAtPoint(start, forDuration: 0, liftAtPoint: end, velocity: 1000, orientation: orientationValue, name: "Monkey drag" as NSString) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    public func addXCTestPinchCloseAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let rect = self!.randomRect(sizeFraction: 2)
            let scale = 1 / CGFloat(self!.r.randomDouble() * 4 + 1)

            let semaphore = DispatchSemaphore(value: 0)
            self!.sharedXCEventGenerator.pinchInRect(rect, withScale: scale, velocity: 1, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    public func addXCTestPinchOpenAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let rect = self!.randomRect(sizeFraction: 2)
            let scale = CGFloat(self!.r.randomDouble() * 4 + 1)

            let semaphore = DispatchSemaphore(value: 0)
            self!.sharedXCEventGenerator.pinchInRect(rect, withScale: scale, velocity: 3, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    public func addXCTestRotateAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let rect = self!.randomRect(sizeFraction: 2)
            let angle = CGFloat(self!.r.randomDouble() * 2 * 3.141592)

            let semaphore = DispatchSemaphore(value: 0)
            self!.sharedXCEventGenerator.rotateInRect(rect, withRotation: angle, velocity: 5, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    public func addXCTestOrientationAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let orientations: [UIDeviceOrientation] = [
                .portrait,
                .portraitUpsideDown,
                .landscapeLeft,
                .landscapeRight,
                .faceUp,
                .faceDown,
            ]

            let index = Int(self!.r.randomUInt32() % UInt32(orientations.count))
            orientationValue = orientations[index]
        }
    }
}

@objc protocol XCEventGenerator {
    static func sharedGenerator() -> XCEventGenerator

    var generation: UInt64 { get set }
    //@property(readonly) NSObject<OS_dispatch_queue> *eventQueue; // @synthesize eventQueue=_eventQueue;

    @discardableResult func rotateInRect(_: CGRect, withRotation: CGFloat, velocity: CGFloat, orientation: UIDeviceOrientation, handler: @escaping () -> Void) -> CGFloat
    @discardableResult func pinchInRect(_: CGRect, withScale: CGFloat, velocity: CGFloat, orientation: UIDeviceOrientation, handler: @escaping () -> Void) -> CGFloat
    @discardableResult func pressAtPoint(_: CGPoint, forDuration: TimeInterval, liftAtPoint: CGPoint, velocity: CGFloat, orientation: UIDeviceOrientation, name: AnyObject, handler: @escaping () -> Void) -> CGFloat
    @discardableResult func pressAtPoint(_: CGPoint, forDuration: TimeInterval, orientation: UIDeviceOrientation, handler: @escaping () -> Void) -> CGFloat
    @discardableResult func tapAtTouchLocations(_: [CGPoint], numberOfTaps: UInt, orientation: UIDeviceOrientation, handler: @escaping () -> Void) -> CGFloat
    func _startEventSequenceWithSteppingCallback(_: () -> Void)
    func _scheduleCallback(_: () -> Void, afterInterval: TimeInterval)

    init()
}
