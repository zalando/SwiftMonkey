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
        let application = XCUIApplication()

        // Workaround for bug in Xcode 7.3. Snapshots are not properly updated
        // when you initially call app.frame, resulting in a zero-sized rect.
        // Doing a random query seems to update everything properly.
        // TODO: Remove this when the Xcode bug is fixed!
        _ = application.descendants(matching: .any).element(boundBy: 0).frame

        // Initialise the monkey tester with the current device
        // frame. Giving an explicit seed will make it generate
        // the same sequence of events on each run, and leaving it
        // out will generate a new sequence on each run.
        let monkey = Monkey(frame: application.frame)
        //let monkey = Monkey(seed: 123, frame: application.frame)

        // Add actions for the monkey to perform. We just use a
        // default set of actions for this, which is usually enough.
        // Use either one of these but maybe not both.
        // XCTest private actions seem to work better at the moment.
        // UIAutomation actions seem to work only on the simulator.
        //monkey.addDefaultXCTestPrivateActions()
        //monkey.addDefaultUIAutomationActions()

        monkey.addAction(weight: 1) {
            let types: Set<XCUIElementType> = [
                .button,
                .statusBar,
                .slider,
                .pageIndicator,
                .segmentedControl,
                .switch,
                .toggle,
                //.link,
                //.searchField,
                //.scrollView,
                .scrollBar,
                //.textField,
                //.secureTextField,
                //.textView,
                .map,
                //.webView,
                .incrementArrow,
                .decrementArrow,
                .ratingIndicator,
                .cell,
                .stepper,
            ]

            let descendants = application.descendants(matching: .any)
            let count = descendants.count
            var elements: [XCUIElement] = []

            for index in 0 ..< count {
                let element = descendants.element(boundBy: index)
                if types.contains(element.elementType) {
                    elements.append(element)
                }
            }

            let index = monkey.randomInt(lessThan: elements.count)
            let element = elements[index]
            let randomOffset = CGVector(dx: monkey.randomCGFloat(), dy:  monkey.randomCGFloat())
            let coordinate = element.coordinate(withNormalizedOffset: randomOffset)
            coordinate.tap()
        }

        // Occasionally, use the regular XCTest functionality
        // to check if an alert is shown, and click a random
        // button on it.
        monkey.addXCTestTapAlertAction(interval: 100, application: application)

        // Run the monkey test indefinitely.
        monkey.monkeyAround()
    }
}
