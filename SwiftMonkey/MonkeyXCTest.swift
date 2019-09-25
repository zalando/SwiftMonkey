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
    
    
    public func addDefaultXCTestPublicActions() {
        addXCTestPublicTapAction(weight: 25)
        addXCTestPublicLongPressAction(weight: 1)
        addXCTestPublicDragAction(weight: 1)
    }
    
    /**
     Add an action that generates a tap, with a possibility for
     multiple taps with multiple fingers, using the private
     XCTest API.
     
     - parameter weight: The relative probability of this
     event being generated. Can be any value larger than
     zero. Probabilities will be normalised to the sum
     of all relative probabilities.
     - parameter multipleTouchProbability: Probability that
     the tap event will use multiple fingers. Between 0 and 1.
     */
    public func addXCTestPublicTapAction(weight: Double,
                                   multipleTouchProbability: Double = 0.05) {
        addAction(weight: weight) { [weak self] in
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
            let app = XCUIApplication()
            let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: locations[0].x/(app.frame.maxX/2), dy: locations[0].y/(app.frame.maxY/2)))
            coordinate.tap()
        }
    }
    
    /**
     Add an action that generates a long press event
     using the private XCTest API.
     
     - Parameter weight: The relative probability of this
     event being generated. Can be any value larger than
     zero. Probabilities will be normalised to the sum
     of all relative probabilities.
     */
    public func addXCTestPublicLongPressAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let point = self!.randomPoint()
            let app = XCUIApplication()
            let coordinate = app.coordinate(withNormalizedOffset: CGVector(dx: point.x/(app.frame.maxX/2), dy: point.y/(app.frame.maxY/2)))
            coordinate.press(forDuration: 0.5)
        }
    }
    
    /**
     Add an action that generates a drag event from one random
     screen position to another using the private XCTest API.
     
     - Parameter weight: The relative probability of this
     event being generated. Can be any value larger than
     zero. Probabilities will be normalised to the sum
     of all relative probabilities.
     */
    public func addXCTestPublicDragAction(weight: Double) {
        addAction(weight: weight) { [weak self] in
            let start = self!.randomPointAvoidingPanelAreas()
            let end = self!.randomPoint()
            let app = XCUIApplication()
            let startCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: start.x/(app.frame.maxX/2), dy: start.y/(app.frame.maxY/2)))
            let endCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: end.x/(app.frame.maxX/2), dy: end.y/(app.frame.maxY/2)))
            startCoordinate.press(forDuration: 0.2, thenDragTo: endCoordinate)
        }
    }
}
