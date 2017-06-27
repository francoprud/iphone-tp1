//
//  MenuScene.swift
//  MyRacingGame
//
//  Created by Franco Prudhomme on 5/1/17.
//  Copyright © 2017 Franco Prudhomme. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, time: CFAbsoluteTime) {
        super.init(size: size)
        backgroundColor = SKColor.white
        let message = String(format: "Finished! Time: %.2fs", time)
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run() {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(fileNamed: "GameScene")
                self.view?.presentScene(scene!, transition:reveal)
            }
            ]))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
