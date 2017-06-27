//
//  Chassis.swift
//  MyRacingGame
//
//  Created by Franco Prudhomme on 5/1/17.
//  Copyright © 2017 Franco Prudhomme. All rights reserved.
//

import SpriteKit
import UIKit

public class Chassis: SKSpriteNode {
    static let MASS: CGFloat = 10
    
    public init(size: CGSize) {
        let texture = SKTexture(imageNamed: "vehicle_1")
        super.init(texture: texture, color: .clear, size: size)
        configurePhysicsBody(size: frame.size)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurePhysicsBody(size: CGSize) {
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.mass = Chassis.MASS
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.Chassis
        self.physicsBody?.contactTestBitMask = PhysicsCategory.FinishLine
        self.physicsBody?.collisionBitMask = PhysicsCategory.Barrier
    }
}
