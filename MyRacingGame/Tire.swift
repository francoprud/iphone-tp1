//
//  Tire.swift
//  MyRacingGame
//
//  Created by Franco Prudhomme on 5/1/17.
//  Copyright © 2017 Franco Prudhomme. All rights reserved.
//

import SpriteKit
import UIKit

public class Tire: SKSpriteNode {
    static let MASS: CGFloat = 10
    
    public var traction: CGFloat = 0.0
    
    public init(size: CGSize) {
        let texture = SKTexture(imageNamed: "tire")
        super.init(texture: texture, color: .clear, size: size)
        configurePhysicsBody(size: size)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurePhysicsBody(size: CGSize) {
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.mass = Tire.MASS
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.Tire
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Grass
        self.physicsBody?.collisionBitMask = PhysicsCategory.Barrier
    }
    
    private func getForwardVelocity() -> CGVector {
        let velocity : CGVector = self.physicsBody!.velocity
        let normal : CGVector = rotate(vector: DirectionsVector.Forward, angle: self.zRotation).normalized()
        return CGVector(dx: normal.dx * pointProduct(vectorA: velocity, vectorB: normal), dy: normal.dy * pointProduct(vectorA: velocity, vectorB: normal))
    }
    
    public func getLateralVelocity() -> CGVector {
        let velocity : CGVector = self.physicsBody!.velocity
        let normal : CGVector = rotate(vector: DirectionsVector.Lateral, angle: self.zRotation).normalized()
        return CGVector(dx: normal.dx * pointProduct(vectorA: velocity, vectorB: normal), dy: normal.dy * pointProduct(vectorA: velocity, vectorB: normal))
    }
    
    public func updateDrive(direction: VehicleDirection) {
        //find desired speed
        var desiredSpeed : CGFloat = 0
        switch direction {
        case .up:
            desiredSpeed = TireSpeed.MaxForward
        case .down:
            desiredSpeed = TireSpeed.MaxBackward
        }
        
        //find current speed in forward direction
        let currentSpeed : CGFloat = getCurrentSpeed()
        
        //apply necessary force
        var force : CGFloat = 0
        if (desiredSpeed > currentSpeed) {
            force = -TireForce.MaxDrive * (1.0 - traction)
        } else if (desiredSpeed < currentSpeed) {
            force = TireForce.MaxDrive * (1.0 - traction)
        } else {
            return
        }
        let currentForwardNormal : CGVector = rotate(vector: DirectionsVector.Forward, angle: self.zRotation)
        self.physicsBody!.applyForce(CGVector(dx: currentForwardNormal.dx * force, dy: currentForwardNormal.dy * force), at: self.position)
    }
    
    private func getCurrentSpeed() -> CGFloat {
        let currentForwardNormal : CGVector = rotate(vector: DirectionsVector.Forward, angle: self.zRotation)
        return pointProduct(vectorA: getForwardVelocity(), vectorB: currentForwardNormal)
    }
    
    public func updateSpin(spin: VehicleSpin, rotation: CGFloat) {
        var desiredTorque : CGFloat = 0.0
        switch spin {
        case .left:
            desiredTorque = 1
        case .right:
            desiredTorque = -1
        }
        self.physicsBody!.applyTorque(desiredTorque)
    }
    
    public func updateFriction() {
        self.physicsBody!.applyImpulse(getImpulse(), at: self.position)
        self.physicsBody?.applyAngularImpulse(-0.1 * (self.physicsBody?.angularDamping)! * (self.physicsBody?.angularVelocity)!)
        applyDragForce()
    }
    
    private func getImpulse() -> CGVector {
        let lateralVelocity : CGVector = getLateralVelocity()
        return CGVector(dx: lateralVelocity.dx * -self.physicsBody!.mass, dy: lateralVelocity.dy * -self.physicsBody!.mass)
    }
    
    private func applyDragForce() {
        let currentForwardNormal : CGVector = getForwardVelocity()
        let currentForwardSpeed : CGFloat = rotate(vector: DirectionsVector.Lateral, angle: self.zRotation).length()
        let dragForceMagnitude : CGFloat = -2 * currentForwardSpeed * traction
        let vector : CGVector = CGVector(dx: currentForwardNormal.dx * dragForceMagnitude, dy: currentForwardNormal.dy * dragForceMagnitude)
        self.physicsBody!.applyForce(vector, at: self.position)
    }
}
