//
//  GameScene.swift
//  MyRacingGame
//
//  Created by Franco Prudhomme on 5/1/17.
//  Copyright © 2017 Franco Prudhomme. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    private static let TOTAL_LAPS = 3
    private var currentLaps = 0
    private var vehicle = Vehicle(color: .yellow)
    private let lapsLabel = SKLabelNode(fontNamed: "Arial")
    private let timerLabel = SKLabelNode(fontNamed: "Arial")
    private var direction: VehicleDirection? = .none
    private var spin: VehicleSpin? = .none
    private var startTime: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    private var endTime: CFAbsoluteTime = 0.0
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        size = view.frame.size
        backgroundColor = .black
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        addVehicle()
        addCamera()
        addButtonsAndLabels()
        addAssets()
    }
    
    private func addVehicle() {
        vehicle.position = CGPoint(x: 0, y: 0)
        addChild(vehicle)
        vehicle.build(scene: self)
    }
    
    private func addCamera() {
        let mainCamera = SKCameraNode()
        camera = mainCamera
        addChild(mainCamera)
    }
    
    private func addButtonsAndLabels() {
        addButtons()
        addLabels()
    }
    
    private func addButtons() {
        let buttonSize = CGSize(width: 60, height: 60)
        let leftButton = SKSpriteNode(texture: SKTexture(imageNamed: "arrow"), size: buttonSize)
        leftButton.position = CGPoint(x: -size.width / 2 + 40, y: -size.height / 2 + leftButton.size.height / 2 + 10)
        leftButton.zRotation = -CGFloat(Double.pi/1.0)
        leftButton.name = "left"
        leftButton.zPosition = 1000
        camera?.addChild(leftButton)
        
        let rightButton = SKSpriteNode(texture: SKTexture(imageNamed: "arrow"), size: buttonSize)
        rightButton.position = CGPoint(x: size.width / 2 - 40, y: -size.height / 2 + rightButton.size.height / 2 + 10)
        rightButton.name = "right"
        rightButton.zPosition = 1000
        camera?.addChild(rightButton)
        
        let downButton = SKSpriteNode(texture: SKTexture(imageNamed: "arrow"), size: buttonSize)
        downButton.position = CGPoint(x: 0, y: -size.height / 2 + downButton.size.height / 2 + 10)
        downButton.zRotation = -CGFloat(Double.pi/2.0)
        downButton.name = "down"
        downButton.zPosition = 1000
        camera?.addChild(downButton)
    }
    
    private func addLabels() {
        timerLabel.text = "0.0s"
        timerLabel.zPosition = 1000
        timerLabel.fontSize = 42
        timerLabel.position = CGPoint(x: 0, y: size.height / 2 - timerLabel.frame.height - 20)
        camera?.addChild(timerLabel)
        
        lapsLabel.text = String(format: "Lap: %d", currentLaps)
        lapsLabel.zPosition = 1000
        lapsLabel.fontSize = 42
        lapsLabel.position = CGPoint(x: size.width / 2 - timerLabel.frame.width - 30, y: size.height / 2 - timerLabel.frame.height - 20)
        camera?.addChild(lapsLabel)
    }
    
    private func addAssets() {
        children.filter { $0.name == "Grass" }
                .forEach {
                    $0.physicsBody = SKPhysicsBody(rectangleOf: $0.frame.size)
                    $0.physicsBody?.isDynamic = false
                    $0.physicsBody?.categoryBitMask = PhysicsCategory.Grass
                    $0.physicsBody?.contactTestBitMask = PhysicsCategory.Tire
                    $0.physicsBody?.collisionBitMask = PhysicsCategory.None
                }
        children.filter { $0.name == "Barrier" }
                .forEach {
                    $0.physicsBody = SKPhysicsBody(rectangleOf: $0.frame.size)
                    $0.physicsBody?.isDynamic = false
                    $0.physicsBody?.categoryBitMask = PhysicsCategory.Barrier
                    $0.physicsBody?.contactTestBitMask = PhysicsCategory.Tire
                    $0.physicsBody?.collisionBitMask = PhysicsCategory.None
        }
        children.filter { $0.name == "FinishLine" }
                .forEach {
                    $0.physicsBody = SKPhysicsBody(rectangleOf: $0.frame.size)
                    $0.physicsBody?.isDynamic = false
                    $0.physicsBody?.categoryBitMask = PhysicsCategory.FinishLine
                    $0.physicsBody?.contactTestBitMask = PhysicsCategory.Chassis
                    $0.physicsBody?.collisionBitMask = PhysicsCategory.None
                    $0.zPosition = 13
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.map { $0.location(in: self) }.map { nodes(at: $0) }.forEach {
            $0.forEach {
                if let directionAux = VehicleDirection(rawValue: $0.name ?? "") {
                    direction = directionAux
                }
                if let spinAux = VehicleSpin(rawValue: $0.name ?? "") {
                    spin = spinAux
                }
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Set direction and spin in nil
        direction = .none
        spin = .none
    }
    
    // Called when two bodies first contact each other
    public func didBegin(_ contact: SKPhysicsContact) {
        // Code extracted from tutorial
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Tire != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Grass != 0)) {
            if let tire = firstBody.node as? Tire {
                tire.traction = 0.7
            }
        }
    }
    
    // Called when the contact ends between two physics bodies
    public  func didEnd(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Tire != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Grass != 0)) {
            if let tire = firstBody.node as? Tire {
                tire.traction = 0.0
            }
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Chassis != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.FinishLine != 0)) {
            currentLaps += 1
        }
    }
    
    // Called after the scene has finished all of the steps required to process animations
    public override func didFinishUpdate() {
        super.didFinishUpdate()
        manageCamera()
    }
    
    // Avoid weird behavior. Thanks A. Ducret for the tip!!
    var a = 0
    public override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if (a <= 10) {
            a += 1
            return
        }
        
        vehicle.updatePhysics(direction: direction, spin: spin)
        
        if currentLaps >= 3 {
            let reveal = SKTransition.flipHorizontal(withDuration: 3)
            let gameOverScene = GameOverScene(size: self.size, time: CFAbsoluteTimeGetCurrent() - startTime)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    private func manageCamera() {
        let vehicleF = vehicle.calculateAccumulatedFrame()
        camera?.position = CGPoint(x: vehicleF.origin.x + vehicleF.width / 2, y: vehicleF.origin.y + vehicleF.height / 2)
        endTime = CFAbsoluteTimeGetCurrent()
        timerLabel.text = String(format: "%.2fs", CFAbsoluteTimeGetCurrent() - startTime)
        lapsLabel.text = String(format: "Lap: %d", currentLaps)
    }
}
