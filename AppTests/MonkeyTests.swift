//
//  SwiftMonkeyExampleUITests.swift
//  SwiftMonkeyExampleUITests
//
//  Created by Dag Agren on 07/11/2016.
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import XCTest
import SwiftMonkey

class SwiftMonkeyExampleUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
                XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMonkey() {
        let useUIAutomation = true
        let application = XCUIApplication()

        // Workaround for bug in Xcode 7.3. Snapshots are not properly updated
        // when you initially call app.frame, resulting in a zero-sized rect.
        // Doing a random query seems to update everything properly.
        // TODO: Remove this when the Xcode bug is fixed!
        _ = application.descendants(matching: .any).element(boundBy: 0).frame

        let monkey = Monkey(seed: 0, frame: application.frame)

        if useUIAutomation {
/*            monkey.addUIAutomationTapActionWithWeight(500)
            monkey.addUIAutomationDragActionWithWeight(1)
            monkey.addUIAutomationFlickActionWithWeight(1)
            monkey.addUIAutomationPinchCloseActionWithWeight(10)
            monkey.addUIAutomationPinchOpenActionWithWeight(10)
            monkey.addUIAutomationOrientationActionWithWeight(1)
            monkey.addUIAutomationClickVolumeUpActionWithWeight(1)
            monkey.addUIAutomationClickVolumeDownActionWithWeight(1)
            monkey.addUIAutomationShakeActionWithWeight(1)
            monkey.addUIAutomationLockActionWithWeight(1)*/

            monkey.addUIAutomationTapActionWithWeight(50)
            monkey.addUIAutomationDragActionWithWeight(1)
            monkey.addUIAutomationFlickActionWithWeight(1)
            monkey.addUIAutomationPinchCloseActionWithWeight(1)
            monkey.addUIAutomationPinchOpenActionWithWeight(1)
            //monkey.addUIAutomationRotateActionWithWeight(1)
            monkey.addUIAutomationOrientationActionWithWeight(1)
            monkey.addUIAutomationClickVolumeUpActionWithWeight(1)
            monkey.addUIAutomationClickVolumeDownActionWithWeight(1)
            monkey.addUIAutomationShakeActionWithWeight(1)
            monkey.addUIAutomationLockActionWithWeight(1)
        } else {
            //monkey.addXCTestSingleTapActionWithWeight(50)
            monkey.addXCTestTapActionWithWeight(50)
            monkey.addXCTestLongPressActionWithWeight(1)
            monkey.addXCTestDragActionWithWeight(1)
            monkey.addXCTestPinchCloseActionWithWeight(1)
            monkey.addXCTestPinchOpenActionWithWeight(1)
            monkey.addXCTestRotateActionWithWeight(1)
            //monkey.addXCTestOrientationActionWithWeight(1)

//            monkey.addXCTestTapActionWithWeight(1)
//            monkey.addXCTestDragActionWithWeight(1)
        }

        monkey.addXCTestTapAlertActionWithInterval(100, application: application)

        monkey.monkeyAround()
    }
    
}
