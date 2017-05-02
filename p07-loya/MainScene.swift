//
//  MainScene.swift
//  p07-loya
//
//  Created by Souritra Dasgupta on 5/2/17.
//  Copyright © 2017 Harshad Loya. All rights reserved.
//

import Foundation
import SpriteKit

class MainScene : SKScene {
    let introsound = SKAction.playSoundFileNamed("intro.wav", waitForCompletion: false)
    let select = SKSpriteNode(imageNamed: "select")
    
    override func didMove(to view: SKView) {
        let bg = SKSpriteNode(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), size: self.size)
        bg.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        bg.zPosition = 0;
        
        let logo = SKSpriteNode(imageNamed: "logo")
        logo.setScale(0.4)
        let contra = SKSpriteNode(imageNamed: "contra")
        contra.position = CGPoint(x: self.size.width/2 + 85, y: self.size.height/2 - 75)
        logo.position = CGPoint(x: self.size.width * 0.8, y: self.size.height/2 + 55)
        select.position = CGPoint(x: contra.position.x - 165, y: contra.position.y + 10)
        let slidein = SKAction.move(to: CGPoint(x: self.size.height * 0.8, y: self.size.height/2 + 55), duration: 3.5)
        let fadein = SKAction.fadeIn(withDuration: 1.2)
        contra.zPosition = 2
        logo.zPosition = 1
        addChild(bg)
        addChild(select)
        addChild(logo)
        addChild(contra)
        bg.run(introsound)
        logo.run(slidein)
        contra.run(fadein)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t: AnyObject in touches{
            let point = t.location(in: self)
            if select.contains(point){
                let toScene = GameScene(size: (view?.bounds.size)!)
                toScene.scaleMode = self.scaleMode
                let move = SKTransition.fade(withDuration: 1)
                self.view!.presentScene(toScene, transition: move)
            }
            }
        }
    }
