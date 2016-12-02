//
//  Random.swift
//  Fleek
//
//  Created by Dag Agren on 14/03/16.
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

/**
    Simple implementation of a PCG random number generator:
    http://www.pcg-random.org/
*/
struct Random {
    var state: UInt64 = 0
    let increment: UInt64

    init() {
        self.init(seed: 0)
    }

    init(seed: UInt32) {
        self.init(seed: 0, sequence: 0)
    }

    init(seed: UInt32, sequence: UInt32) {
        state = 0
        increment = (UInt64(sequence) << 1) | 1
        _ = randomUInt32()
        state = state &+ UInt64(seed)
        _ = randomUInt32()
    }

    mutating func randomUInt32() -> UInt32 {
        let oldstate = state
        state = oldstate &* 6364136223846793005 &+ increment
        let xorshifted = UInt32((((oldstate >> 18) ^ oldstate) >> 27) & 0xffffffff)
        let rot = UInt32(oldstate >> 59)
        return (xorshifted >> rot) | (xorshifted << UInt32(-Int(rot) & 31))
    }

    mutating func randomInt(lessThan: Int) -> Int {
        return Int(randomUInt32() % UInt32(lessThan))
    }

    mutating func randomUInt(lessThan: UInt) -> UInt {
        return UInt(randomUInt32() % UInt32(lessThan))
    }

    mutating func randomFloat() -> Float {
        return Float(randomUInt32()) / 4294967296.0
    }

    mutating func randomFloat(lessThan: Float) -> Float {
        return randomFloat() * lessThan
    }

    mutating func randomDouble() -> Double {
        return Double(randomUInt32()) / 4294967296.0
    }

    mutating func randomDouble(lessThan: Double) -> Double {
        return randomDouble() * lessThan
    }
}
