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

var orientationValue: UIDeviceOrientation = .portrait

extension Monkey {
    var sharedXCEventGenerator: XCEventGenerator {
        let generatorClass = unsafeBitCast(NSClassFromString("XCEventGenerator"),to: XCEventGenerator.Type.self)
        return generatorClass.sharedGenerator()
    }

    func addXCTestSingleTapActionWithWeight(_ weight: Double) {
        addActionWithWeight(weight) { [weak self] in
            let point = self!.randomPoint()

            let semaphore = DispatchSemaphore(value: 0)
            _ = self!.sharedXCEventGenerator.tapAtPoint(point, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    func addXCTestTapActionWithWeight(_ weight: Double, multipleTapProbability: Double = 0.05,
    multipleTouchProbability: Double = 0.05) {
        addActionWithWeight(weight) { [weak self] in
            let numberOfTaps: Int
            if self!.r.randomDouble()<multipleTapProbability {
                numberOfTaps = Int(self!.r.randomUInt32() % 2) + 2
            } else {
                numberOfTaps = 1
            }

            let numberOfTouches: Int
            if self!.r.randomDouble()<multipleTouchProbability {
                numberOfTouches = Int(self!.r.randomUInt32() % 2) + 2
            } else {
                numberOfTouches = 1
            }

            let rect = self!.randomRect()

            let semaphore = DispatchSemaphore(value: 0)
            _ = self!.sharedXCEventGenerator.tapWithNumberOfTaps(UInt64(numberOfTaps), numberOfTouches: UInt64(numberOfTouches), inRect: rect, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    func addXCTestLongPressActionWithWeight(_ weight: Double) {
        addActionWithWeight(weight) { [weak self] in
            let point = self!.randomPoint()
            let semaphore = DispatchSemaphore(value: 0)
            _ = self!.sharedXCEventGenerator.pressAtPoint(point, forDuration: 0.5, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    func addXCTestDragActionWithWeight(_ weight: Double) {
        addActionWithWeight(weight) { [weak self] in
            let start = self!.randomPoint()
            let end = self!.randomPoint()

            let semaphore = DispatchSemaphore(value: 0)
            _ = self!.sharedXCEventGenerator.pressAtPoint(start, forDuration: 0, liftAtPoint: end, velocity: 1000, orientation: orientationValue, name: "Monkey drag" as NSString) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    func addXCTestPinchCloseActionWithWeight(_ weight: Double) {
        addActionWithWeight(weight) { [weak self] in
            let rect = self!.randomRectWithSizeFraction(2)
            let scale: Double = 1 / (self!.r.randomDouble() * 4 + 1)

            let semaphore = DispatchSemaphore(value: 0)
            _ = self!.sharedXCEventGenerator.pinchInRect(rect, withScale: scale, velocity: 1, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    func addXCTestPinchOpenActionWithWeight(_ weight: Double) {
        addActionWithWeight(weight) { [weak self] in
            let rect = self!.randomRectWithSizeFraction(2)
            let scale: Double = self!.r.randomDouble() * 4 + 1

            let semaphore = DispatchSemaphore(value: 0)
            _ = self!.sharedXCEventGenerator.pinchInRect(rect, withScale: scale, velocity: 3, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    func addXCTestRotateActionWithWeight(_ weight: Double) {
        addActionWithWeight(weight) { [weak self] in
            let rect = self!.randomRectWithSizeFraction(2)
            let angle = self!.r.randomDouble() * 2 * 3.141592

            let semaphore = DispatchSemaphore(value: 0)
            _ = self!.sharedXCEventGenerator.rotateInRect(rect, withRotation: angle, velocity: 5, orientation: orientationValue) {
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    func addXCTestOrientationActionWithWeight(_ weight: Double) {
        addActionWithWeight(weight) { [weak self] in
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



@objc protocol XCTestDriver {
    static func sharedTestDriver() -> XCTestDriver

    var daemonProtocolVersion: UInt64 { get }
    var hasIDEConnection: Bool { get }
    var waitingToStart: Bool { get }
    var IDEProtocolVersion: Int64 { get }
    //weak var IDEProxy: XCTestManager_IDEInterface { get }

    //var IDEConnection: DTXConnection { get }
    var sessionIdentifier: NSUUID { get }
    //var currentTestSuite: XCTestSuite { get }

    func _XCT_receivedAccessibilityNotification(_: Int, withPayload: AnyObject) 
    func _XCT_applicationWithBundleID(_: AnyObject, didUpdatePID: Int, andState: UInt64)
    func _IDE_startExecutingTestPlanWithProtocolVersion(_: AnyObject) -> AnyObject
    func runTestConfiguration(_: AnyObject, completionHandler: () -> Void)
    func runTestSuite(_: AnyObject, completionHandler: () -> Void)
    func _checkForTestManager()
    func _connectToTestManager()
    func _checkManagerDaemonStateAndConnectIfAvailable()
    func _resetManagerConnection()
    func _connectToIDEWithTransport(_: AnyObject)
    func _runSuite()
    func resumeAppSleep(_: AnyObject)
    func suspendAppSleep() -> AnyObject

    //weak var managerProxy: XCTestManager_ManagerInterface { get }

    func _softlinkDTXConnectionServices()
    func flushLogs()
    func logDebugMessage(_: AnyObject)

    init()

    var debugDescription: String { get }
    var description: String { get }
    var hash: UInt64 { get }
}

@objc protocol  XCTestManager_ManagerInterface {
    func _XCT_requestScreenshotWithReply(_: () -> Void)
    func _XCT_sendString(_: String, completion: () -> Void)
    func _XCT_sendString(_: String, maximumFrequency: UInt64, completion: () -> Void)
    func _XCT_updateDeviceOrientation(_: Int64, completion: () -> Void)
    //func _XCT_performDeviceEvent(_: XCDeviceEvent, completion: () -> Void)
    func _XCT_performTouchGesture(_: XCTouchGesture, completion: () -> Void)
    //func _XCT_synthesizeEvent(_: XCSynthesizedEventRecord, completion: () -> Void)
    func _XCT_requestElementAtPoint(_: CGPoint, reply: () -> Void)
    //func _XCT_fetchParameterizedAttributeForElement(_: XCAccessibilityElement, attributes: Int, parameter: AnyObject, reply: () -> Void)
    //func _XCT_fetchAttributesForElement(_: XCAccessibilityElement, attributes: [AnyObject], reply: () -> Void)
    //func _XCT_snapshotForElement(_: XCAccessibilityElement, attributes: [AnyObject], parameters: [NSObject : AnyObject], reply: () -> Void)
    func _XCT_terminateApplicationWithBundleID(_: String, completion: () -> Void)
    //func _XCT_performAccessibilityAction(_: Int, onElement: XCAccessibilityElement, withValue: AnyObject, reply: () -> Void)
    func _XCT_unregisterForAccessibilityNotification(_: Int, withRegistrationToken: Int, reply: () -> Void)
    func _XCT_registerForAccessibilityNotification(_: Int, reply: () -> Void)
    func _XCT_launchApplicationWithBundleID(_: String, arguments: [AnyObject], environment: [NSObject : AnyObject], completion: () -> Void)
    func _XCT_startMonitoringApplicationWithBundleID(_: String)
    func _XCT_requestBackgroundAssertionWithReply(_: () -> Void)
    func _XCT_requestSocketForSessionIdentifier(_: NSUUID, reply: () -> Void)
    func _XCT_exchangeProtocolVersion(_: UInt64, reply: () -> Void) 
}

@objc protocol XCTouchGesture {
    static func supportsSecureCoding() -> Bool
    var immutable: Bool { get }
    var name: String { get }
    var description: String { get }
    var maximumOffset: Double { get }

    func makeImmutable()
    func addTouchPath(_: AnyObject)

    var touchPaths: [AnyObject] { get }

    func encodeWithCoder(_: AnyObject)
    init(coder _: AnyObject)
    init(name _: AnyObject)
    init()
}

@objc protocol XCEventGenerator {
    static func sharedGenerator() -> XCEventGenerator

    var generation: UInt64 { get set }
    //@property(readonly) NSObject<OS_dispatch_queue> *eventQueue; // @synthesize eventQueue=_eventQueue;

    func rotateInRect(_: CGRect, withRotation: Double, velocity: Double, orientation: UIDeviceOrientation, handler: () -> Void) -> Double
    func pinchInRect(_: CGRect, withScale: Double, velocity: Double, orientation: UIDeviceOrientation, handler: () -> Void) -> Double
    func pressAtPoint(_: CGPoint, forDuration: Double, liftAtPoint: CGPoint, velocity: Double, orientation: UIDeviceOrientation, name: AnyObject, handler: () -> Void) -> Double
    func pressAtPoint(_: CGPoint, forDuration: Double, orientation: UIDeviceOrientation, handler: () -> Void) -> Double
    func tapWithNumberOfTaps(_: UInt64, numberOfTouches: UInt64, inRect: CGRect, orientation: UIDeviceOrientation, handler: (() -> Void)?) -> Double
    func twoFingerTapInRect(_: CGRect, orientation: UIDeviceOrientation, handler: () -> Void) -> Double
    func doubleTapAtPoint(_: CGPoint, orientation: UIDeviceOrientation, handler: () -> Void) -> Double
    func tapAtPoint(_: CGPoint, orientation: UIDeviceOrientation, handler: () -> Void) -> Double
    func _startEventSequenceWithSteppingCallback(_: () -> Void)
    func _scheduleCallback(_: () -> Void, afterInterval: Double)

    init()
}


