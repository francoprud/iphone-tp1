//
//  PhysicsCategory.swift
//  MyRacingGame
//
//  Created by Franco Prudhomme on 5/1/17.
//  Copyright © 2017 Franco Prudhomme. All rights reserved.
//

public struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let Chassis   : UInt32 = 0b1
    static let Tire      : UInt32 = 0b10
    static let Barrier   : UInt32 = 0b100
    static let Grass     : UInt32 = 0b1000
    static let FinishLine: UInt32 = 0b10000
    static let All       : UInt32 = UInt32.max
}
