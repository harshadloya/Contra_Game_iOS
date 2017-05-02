//
//  GameOver.swift
//  p07-loya
//
//  Created by Souritra Dasgupta on 5/2/17.
//  Copyright © 2017 Harshad Loya. All rights reserved.
//

import Foundation
import SpriteKit

class GameOver: SKScene{
    let restartlabel = SKLabelNode(fontNamed: "Pixel-Noir Caps")
    override func didMove(to view: SKView) {
        let bg = SKSpriteNode(color: #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1), size: self.size)
        bg.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        bg.zPosition = 0;
        let label = SKLabelNode(fontNamed: "Pixel-Noir Caps")
        let label1 = SKLabelNode(fontNamed: "Pixel-Noir Caps")
        label1.text = "Game Over"
        label.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        label.fontColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.fontSize = 40
        label.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        label.zPosition = 1
        restartlabel.fontColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        restartlabel.text = "RESTART"
        restartlabel.fontSize = 20
        restartlabel.zPosition = 1
        restartlabel.position = CGPoint(x: self.size.width/2, y: label.position.y - 65)
        label1.position = CGPoint(x: self.size.width/2, y: label.position.y - 30)
        self.addChild(restartlabel)
        self.addChild(bg)
        self.addChild(label)
        self.addChild(label1)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t: AnyObject in touches{
            let point = t.location(in: self)
            if restartlabel.contains(point) {
                let toScene = MainScene(size: self.size)
                toScene.scaleMode = self.scaleMode
                let move = SKTransition.fade(withDuration: 1)
                self.view!.presentScene(toScene, transition: move)
            }
        }
    }
}
