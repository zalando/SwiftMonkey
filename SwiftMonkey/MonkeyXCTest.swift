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
    /// Generates a random `CGVector` inside the frame of the app.
    public func randomOffset() -> CGVector {
        let point = randomPoint()
        return CGVector(dx: point.x, dy: point.y)
    }
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
    
    public func addDefaultXCTestPublicActions(app: XCUIApplication) {
        addXCTestPublicTapAction(app: app, weight: 25)
        addXCTestPublicLongPressAction(app: app, weight: 1)
        addXCTestPublicDragAction(app: app, weight: 1)
    }
    
    
    /// Add an action that generates a tap, with a possibility for double taps, using the public XCTest API.
    /// - Parameter app: The application proxy.
    /// - Parameter weight: The relative probability of this event being generated. Can be any value larger than zero. Probabilities
    /// will be normalised to the sum of all relative probabilities.
    /// - Parameter doubleTapProbability: Probability that a double tap event is used. Between 0 and 1.
    public func addXCTestPublicTapAction(app: XCUIApplication,
                                         weight: Double,
                                         doubleTapProbability: Double = 0.05) {
        addAction(weight: weight) { [unowned self] in
            let doubleTap = self.r.randomDouble() < doubleTapProbability
            let coordinate = app.coordinate(withNormalizedOffset: .zero).withOffset(self.randomOffset())
            
            if doubleTap {
                coordinate.doubleTap()
            } else {
                coordinate.tap()
            }
        }
    }
    
    
    /// Add an action that generates a long press event using the public XCTest API.
    /// - Parameter app: The application proxy.
    /// - Parameter weight: The relative probability of this event being generated. Can be any value larger than zero. Probabilities
    /// will be normalised to the sum of all relative probabilities.
    public func addXCTestPublicLongPressAction(app: XCUIApplication,
                                               weight: Double) {
        addAction(weight: weight) { [unowned self] in
            let coordinate = app.coordinate(withNormalizedOffset: .zero).withOffset(self.randomOffset())
            coordinate.press(forDuration: 0.5)
        }
    }
    

    /// Add an action that generates a drag event from one random screen position to another using the public XCTest API.
    /// - Parameter app: The application proxy.
    /// - Parameter weight: The relative probability of this event being generated. Can be any value larger than zero. Probabilities
    /// will be normalised to the sum of all relative probabilities.
    public func addXCTestPublicDragAction(app: XCUIApplication,
                                          weight: Double) {
        addAction(weight: weight) { [unowned self] in
            let startCoordinate = app.coordinate(withNormalizedOffset: .zero).withOffset(self.randomOffset())
            let endCoordinate = app.coordinate(withNormalizedOffset: .zero).withOffset(self.randomOffset())
            startCoordinate.press(forDuration: 0.2, thenDragTo: endCoordinate)
        }
    }
}
