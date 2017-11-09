//
//  MonkeyXCTest.swift
//  Fleek
//
//  Created by Dag Agren on 23/03/16.
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation
import XCTest

/**
    Extension using the public XCTest API to generate
    events.
*/
@available(iOS 9.0, *)
extension Monkey {

    /**
        Add an action that checks, at a fixed interval,
        if an alert is being displayed, and if so, selects
        a random button on it.

        - parameter interval: How often to generate this
          event. One of these events will be generated after
          this many randomised events have been generated.
        - parameter application: The `XCUIApplication` object
          for the current application.
    */
    public func addXCTestTapAlertAction(interval: Int, application: XCUIApplication) {
        addAction(interval: interval) { [weak self] in
            // The test for alerts on screen and dismiss them if there are any.
            for i in 0 ..< application.alerts.count {
                let alert = application.alerts.element(boundBy: i)
                let buttons = alert.descendants(matching: .button)
                XCTAssertNotEqual(buttons.count, 0, "No buttons in alert")
                let index = self!.r.randomInt(lessThan: buttons.count)
                let button = buttons.element(boundBy: index)
                button.tap()
            }
        }
    }
}
