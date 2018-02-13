//
//  Configuration.swift
//  SwiftMonkeyPaws
//
//  Created by Daniel.Metzing on 11.02.18.
//

import UIKit

public struct Configuration {
    // Customise the appearance of the paws
    public struct Paws {

        /// Define the colour of the Paws
        ///
        /// - randomized: random colour for each paw
        /// - constant: same colour for the paws
        public enum Color {
            case randomized
            case constant(UIColor)
        }
        // Colour of the paws
        public let color: Color

        // Brightness of a particular paw
        public let brightness: CGFloat

        // Maximum visible paws at one time
        public let maxShown: Int

        public init(colour: Color = .randomized, brightness: CGFloat = 0.5, maxShown: Int = 15) {
            self.color = colour
            self.brightness = brightness
            self.maxShown = maxShown
        }
    }

    public struct Radius {

        /// Radius of the cross draw upon canceling a touch event
        public let cross: CGFloat

        /// Radius of the circle draw upon ending a touch event
        public let circle: CGFloat

        public init(cross: CGFloat = 7, circle: CGFloat = 7) {
            self.cross = cross
            self.circle = circle
        }
    }

    public let paws: Paws
    public let radius: Radius

    public init(paws: Paws = Paws(), radius: Radius = Radius()) {
        self.paws = paws
        self.radius = radius
    }
}
