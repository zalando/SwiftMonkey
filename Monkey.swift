//
//  Monkey.swift
//  Fleek
//
//  Created by Dag Agren on 16/03/16.
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import UIKit

public class Monkey {
    var r: Random
    let frame: CGRect

    var randomActions: [(accumulatedWeight: Double, action: (Void) -> Void)]
    var totalWeight: Double

    var regularActions: [(interval: Int, action: (Void) -> Void)]
    var actionCounter = 0

    public init(seed: UInt32, frame: CGRect) {
        self.r = Random(seed: seed)
        self.frame = frame
        self.randomActions = []
        self.totalWeight = 0
        self.regularActions = []
    }

    public func monkeyAround(iterations: Int) {
        for _ in 1 ... iterations {
            actRandomly()
            actRegularly()
        }
    }

    public func monkeyAround() {
        while true {
            actRandomly()
            actRegularly()
        }
    }

    public func actRandomly() {
        let x = r.randomDouble() * totalWeight
        for action in randomActions {
            if x < action.accumulatedWeight {
                action.action()
                return
            }
        }
    }

    public func actRegularly() {
        actionCounter += 1

        for action in regularActions {
            if actionCounter % action.interval == 0 {
                action.action()
                return
            }
        }
    }

    public func addAction(weight: Double, action: @escaping (Void) -> Void) {
        totalWeight += weight
        randomActions.append((accumulatedWeight: totalWeight, action: action))
    }

    public func addAction(interval: Int, action: @escaping (Void) -> Void) {
        regularActions.append((interval: interval, action: action))
    }

    public func randomPoint() -> CGPoint {
        return randomPoint(inRect: frame)
    }

    public func randomPoint(inRect rect: CGRect) -> CGPoint {
        return CGPoint(x: rect.origin.x+rect.size.width*CGFloat(r.randomDouble()), y: rect.origin.y+rect.size.height*CGFloat(r.randomDouble()))
    }

    public func randomRect() -> CGRect {
        return rect(around: randomPoint(), inRect: frame)
    }

    public func randomRect(sizeFraction: CGFloat) -> CGRect {
        return rect(around: randomPoint(), sizeFraction: sizeFraction, inRect: frame)
    }

    public func randomClusteredPoints(count: Int) -> [CGPoint] {
        let centre = randomPoint()
        let clusterRect = rect(around: centre, inRect: frame)

        var points = [ centre ]
        for _ in 1..<count {
            points.append(randomPoint(inRect: clusterRect))
        }

        return points
    }

    func rect(around point: CGPoint, sizeFraction: CGFloat = 3, inRect: CGRect) -> CGRect {
        let size: CGFloat = min(frame.size.width, frame.size.height) / sizeFraction
        let x0: CGFloat = (point.x - frame.origin.x) * (frame.size.width - size) / frame.size.width + frame.origin.x
        let y0: CGFloat = (point.y - frame.origin.y) * (frame.size.height - size) / frame.size.width  + frame.origin.y
        return CGRect(x: x0, y: y0, width: size, height: size)
    }

    func sleep(_ seconds: Double) {
        if seconds>0 {
            usleep(UInt32(seconds * 1000000.0))
        }
    }
}

