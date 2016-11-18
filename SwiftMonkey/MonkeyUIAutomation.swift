//
//  MonkeyUIAutomation.swift
//  Fleek
//
//  Created by Dag Agren on 23/03/16.
//  Copyright © 2016 Zalando SE. All rights reserved.
//
//  Event generation using the private UIAutomation framework.
//  Does not seem to work on actual devices for unknown reasons.
//

import UIKit

private let eventGenerator: UIASyntheticEvents = {
    let url = URL(fileURLWithPath: "/Developer/Library/PrivateFrameworks/UIAutomation.framework/UIAutomation")

    url.withUnsafeFileSystemRepresentation() { representation -> Void in
        dlopen(representation, RTLD_LOCAL)
    }

    let eventsclass = unsafeBitCast(NSClassFromString("UIASyntheticEvents"), to: UIASyntheticEvents.Type.self)
    return eventsclass.sharedEventGenerator()
}()

extension Monkey {
    public func addDefaultUIAutomationActions() {
        addUIAutomationTapAction(weight: 50)
        addUIAutomationDragAction(weight: 1)
        addUIAutomationFlickAction(weight: 1)
        addUIAutomationPinchCloseAction(weight: 1)
        addUIAutomationPinchOpenAction(weight: 1)
        //addUIAutomationRotateAction(weight: 1) // TODO: Investigate why this is broken.
        addUIAutomationOrientationAction(weight: 1)
        addUIAutomationClickVolumeUpAction(weight: 1)
        addUIAutomationClickVolumeDownAction(weight: 1)
        addUIAutomationShakeAction(weight: 1)
        addUIAutomationLockAction(weight: 1)
    }

    public func addUIAutomationSingleTapAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            eventGenerator.sendTap(self!.randomPoint())
        }
    }

    public func addUIAutomationTapAction(weight: Double, multipleTapProbability: Double = 0.05,
    multipleTouchProbability: Double = 0.05, longPressProbability: Double = 0.05) {
        addAction(weight: weight) { [weak self] in
            let numberOfTaps: Int
            if self!.r.randomDouble()<multipleTapProbability {
                numberOfTaps = Int(self!.r.randomUInt32() % 2) + 2
            } else {
                numberOfTaps = 1
            }

            let touches: [CGPoint]
            if self!.r.randomDouble()<multipleTouchProbability {
                let count = Int(self!.r.randomUInt32() % 2) + 2
                touches = self!.randomClusteredPoints(count: count)
            } else {
                touches = [ self!.randomPoint() ]
            }

            let duration: Double
            if self!.r.randomDouble()<longPressProbability { duration = 0.5 }
            else { duration = 0 }

            for i in 1...numberOfTaps {
                eventGenerator.touchDownAtPoints(touches, touchCount: UInt64(touches.count))
                self!.sleep(duration)
                eventGenerator.liftUpAtPoints(touches, touchCount: UInt64(touches.count))
                if i != numberOfTaps { self!.sleep(0.2) }
            }
        }
    }

    public func addUIAutomationDragAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let start = self!.randomPoint()
            let end = self!.randomPoint()
            eventGenerator.sendDragWithStartPoint(start, endPoint: end, duration: 0.5)
        }
    }

    public func addUIAutomationFlickAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let start = self!.randomPoint()
            let end = self!.randomPoint()
            eventGenerator.sendFlickWithStartPoint(start, endPoint: end, duration: 0.5)
        }
    }

    public func addUIAutomationPinchCloseAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let start = self!.randomPoint()
            let end = self!.randomPoint()
            eventGenerator.sendPinchCloseWithStartPoint(start, endPoint: end, duration: 0.5)
        }
    }

    public func addUIAutomationPinchOpenAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let start = self!.randomPoint()
            let end = self!.randomPoint()
            eventGenerator.sendPinchOpenWithStartPoint(start, endPoint: end, duration: 0.5)
        }
    }

    public func addUIAutomationRotateAction(weight: Double) {
        // Not working for some reason.
        addAction(weight: weight) { [weak self] in
            let point = self!.randomPoint()
            let radius = self!.r.randomDouble() * 100 + 50
            let angle = self!.r.randomDouble() * 2 * M_PI
            eventGenerator.sendRotate(point, withRadius: radius, rotation: angle, duration: 0.5, touchCount: 2)
        }
    }

    public func addUIAutomationOrientationAction(weight: Double) {
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
            let orientation = orientations[index]

            eventGenerator.setOrientation(Int32(orientation.rawValue))
            self!.sleep(0.9)
        }
    }

    public func addUIAutomationClickVolumeUpAction(weight: Double) {
        addAction(weight: weight) {
            eventGenerator.clickVolumeUp()
        }
    }

    public func addUIAutomationClickVolumeDownAction(weight: Double) {
        addAction(weight: weight) {
            eventGenerator.clickVolumeDown()
        }
    }

    public func addUIAutomationShakeAction(weight: Double) {
        addAction(weight: weight) {
            eventGenerator.shake()
        }
    }

    public func addUIAutomationLockAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let duration = 3 * self!.r.randomDouble()
            eventGenerator.lockDevice()
            self!.sleep(duration)
            eventGenerator.sendDragWithStartPoint(CGPoint(x: 20, y: 400), endPoint: CGPoint(x: 300, y: 400), duration: 0.5)
        }
    }
}




@objc protocol UIASyntheticEvents {
    static func sharedEventGenerator() -> UIASyntheticEvents

    //@property(readonly) struct __IOHIDEventSystemClient *ioSystemClient; // @synthesize ioSystemClient=_ioSystemClient;
    var voiceOverStyleTouchEventsEnabled: Bool { get set }
    var activePointCount: UInt64 { get set }
    //@property(nonatomic) CDStruct_3eca2549 *activePoints; // @synthesize activePoints=_activePoints;
    var gsScreenScale: Double { get set }
    var gsScreenSize: CGSize { get set }
    var screenSize: CGSize { get set }
    var screen: UIScreen { get set }
    var onScreenRect: CGRect { get set }

    func sendPinchCloseWithStartPoint(_: CGPoint, endPoint: CGPoint, duration: Double, inRect: CGRect)
    func sendPinchOpenWithStartPoint(_: CGPoint, endPoint: CGPoint, duration: Double, inRect: CGRect)
    func sendDragWithStartPoint(_: CGPoint, endPoint: CGPoint, duration: Double, withFlick: Bool, inRect: CGRect)
    func sendRotate(_: CGPoint, withRadius: Double, rotation: Double, duration: Double, touchCount: UInt64)
    func sendMultifingerDragWithPointArray(_: UnsafePointer<CGPoint>, numPoints: Int32, duration: Double, numFingers: Int32)
    func sendPinchCloseWithStartPoint(_: CGPoint, endPoint: CGPoint, duration: Double)
    func sendPinchOpenWithStartPoint(_: CGPoint, endPoint: CGPoint, duration: Double)
    func sendFlickWithStartPoint(_: CGPoint, endPoint: CGPoint, duration: Double)
    func sendDragWithStartPoint(_: CGPoint, endPoint: CGPoint, duration: Double)
    func sendTaps(_: Int, location: CGPoint, withNumberOfTouches: Int, inRect: CGRect)
    func sendDoubleFingerTap(_: CGPoint)
    func sendDoubleTap(_: CGPoint)
    func _sendTap(_: CGPoint, withPressure: Double)
    func sendTap(_: CGPoint)
    func _setMajorRadiusForAllPoints(_: Double)
    func _setPressureForAllPoints(_: Double)
    func moveToPoints(_: UnsafePointer<CGPoint>, touchCount: UInt64, duration: Double)
    func _moveLastTouchPoint(_: CGPoint)
    func liftUp(_: CGPoint)
    func liftUp(_: CGPoint, touchCount: UInt64)
    func liftUpAtPoints(_: UnsafePointer<CGPoint>, touchCount: UInt64)
    func touchDown(_: CGPoint)
    func touchDown(_: CGPoint, touchCount: UInt64)
    func touchDownAtPoints(_: UnsafePointer<CGPoint>, touchCount: UInt64)
    func shake()
    func setRinger(_: Bool)
    func holdVolumeDown(_: Double)
    func clickVolumeDown()
    func holdVolumeUp(_: Double)
    func clickVolumeUp()
    func holdLock(_: Double)
    func clickLock()
    func lockDevice()
    func holdMenu(_: Double)
    func clickMenu()
    func _sendSimpleEvent(_: Int)
    func setOrientation(_: Int32)
    func sendAccelerometerX(_: Double, Y: Double, Z: Double, duration: Double)
    func sendAccelerometerX(_: Double, Y: Double, Z: Double)
    func _updateTouchPoints(_: UnsafePointer<CGPoint>, count: UInt64)
    func _sendHIDVendorDefinedEvent(_: UInt32, usage: UInt32, data: UnsafePointer<UInt8>, dataLength: UInt32) -> Bool
    func _sendHIDScrollEventX(_: Double, Y: Double, Z: Double) -> Bool
    func _sendHIDKeyboardEventPage(_: UInt32, usage: UInt32, duration: Double) -> Bool
    //- (_Bool)_sendHIDEvent:(struct __IOHIDEvent *)arg1;
    //- (struct __IOHIDEvent *)_UIACreateIOHIDEventType:(unsigned int)arg1;    func _isEdgePoint(_: CGPoint) -> Bool
    func _normalizePoint(_: CGPoint) -> CGPoint
    //- (void)dealloc;
    func _initScreenProperties()
    //- (id)init;
}
