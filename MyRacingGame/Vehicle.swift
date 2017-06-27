//
//  Vehicle.swift
//  MyRacingGame
//
//  Created by Franco Prudhomme on 5/1/17.
//  Copyright © 2017 Franco Prudhomme. All rights reserved.
//

import SpriteKit
import UIKit

public class Vehicle: SKNode {
    static let TIRE_SIZE: CGSize = CGSize(width: VehicleDimension.TireWidth, height: VehicleDimension.TireHeight)
    static let TORQUE_FRICTION : CGFloat = 0.2

    private var chassis: Chassis = Chassis(size: CGSize(width: VehicleDimension.ChassisWidth, height: VehicleDimension.ChassisHeight))
    private var leftFrontTire  : Tire = Tire(size: Vehicle.TIRE_SIZE)
    private var rightFrontTire : Tire = Tire(size: Vehicle.TIRE_SIZE)
    private var leftBackTire   : Tire = Tire(size: Vehicle.TIRE_SIZE)
    private var rightBackTire  : Tire = Tire(size: Vehicle.TIRE_SIZE)
    
    public init(color: UIColor) {
        super.init()
        addChassisAndTires()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addChassisAndTires() {
        // Place Chassis
        chassis.zPosition = 20
        chassis.position = CGPoint(x: 10, y: 35)
        addChild(chassis)
        
        // Place Tires
        leftBackTire.zPosition = 15
        leftBackTire.position = CGPoint(x: -5, y: 60)
        addChild(leftBackTire)
        
        rightBackTire.zPosition = 15
        rightBackTire.position = CGPoint(x: 25, y: 60)
        addChild(rightBackTire)
        
        leftFrontTire.zPosition = 15
        leftFrontTire.position = CGPoint(x: -5, y: 5)
        addChild(leftFrontTire)
        
        rightFrontTire.zPosition = 15
        rightFrontTire.position = CGPoint(x: 25, y: 5)
        addChild(rightFrontTire)
    }
    
    public func build(scene: SKScene) {
        var mainJoint = SKPhysicsJointPin.joint(withBodyA: chassis.physicsBody!, bodyB: leftFrontTire.physicsBody!, anchor: leftFrontTire.position)
        mainJoint.shouldEnableLimits = true
        mainJoint.lowerAngleLimit = CGFloat(-(Double.pi/4.0))
        mainJoint.upperAngleLimit = CGFloat(Double.pi/4.0)
        mainJoint.frictionTorque = Vehicle.TORQUE_FRICTION
        scene.physicsWorld.add(mainJoint)
        
        mainJoint = SKPhysicsJointPin.joint(withBodyA: chassis.physicsBody!, bodyB: rightFrontTire.physicsBody!, anchor: rightFrontTire.position)
        mainJoint.shouldEnableLimits = true
        mainJoint.lowerAngleLimit = CGFloat(-(Double.pi/4.0))
        mainJoint.upperAngleLimit = CGFloat(Double.pi/4.0)
        mainJoint.frictionTorque = Vehicle.TORQUE_FRICTION
        scene.physicsWorld.add(mainJoint)
        
        var joint = SKPhysicsJointFixed.joint(withBodyA: chassis.physicsBody!, bodyB: leftBackTire.physicsBody!, anchor: leftBackTire.position)
        scene.physicsWorld.add(joint)
        
        joint = SKPhysicsJointFixed.joint(withBodyA: chassis.physicsBody!, bodyB: rightBackTire.physicsBody!, anchor: rightBackTire.position)
        scene.physicsWorld.add(joint)
    }
    
    public func updatePhysics(direction: VehicleDirection? = .none, spin: VehicleSpin? = .none) {
        updateTirePhysics(frontal: true, tire: leftFrontTire, direction: direction, spin: spin)
        updateTirePhysics(frontal: true, tire: rightFrontTire, direction: direction, spin: spin)
        updateTirePhysics(frontal: false, tire: leftBackTire, direction: direction, spin: spin)
        updateTirePhysics(frontal: false, tire: rightBackTire, direction: direction, spin: spin)
    }
    
    private func updateTirePhysics(frontal: Bool, tire: Tire, direction: VehicleDirection?, spin: VehicleSpin?) {
        tire.updateFriction()
        
        if frontal {
            if let spin = spin {
                tire.updateSpin(spin: spin, rotation: chassis.zRotation)
            }
        }
        
        if let direction = direction {
            tire.updateDrive(direction: direction)
        } else {
            tire.updateDrive(direction: .up)
        }
    }
}
