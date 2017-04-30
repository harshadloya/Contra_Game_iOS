//
//  GameScene.swift
//  p07-loya
//
//  Created by Harshad Loya on 4/20/17.
//  Copyright © 2017 Harshad Loya. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene
{
    
    var screenWidth = CGFloat()
    var screenHeight = CGFloat()
    
    var gameBase = SKNode()
    var gameBaseTile = SKShapeNode()

    var noOfTilesInARow = Int()
    var noOfTilesInAColumn = Int()
    
    var base = SKShapeNode()
    var controller = SKShapeNode()
    var speedController = SKSpriteNode()
    var controllerPressed = Bool()
    var controllerMoved = Bool()
    var speedControllerPressed = Bool()
    var speedBooster = CGFloat()
    
    var xDist = CGFloat()
    var yDist = CGFloat()
    
    override func didMove(to view: SKView)
    {
        screenWidth = self.frame.size.width
        screenHeight = self.frame.size.height
        
        noOfTilesInARow = Int(screenWidth) / 30
        noOfTilesInAColumn = Int(screenHeight) / 30
        
        for i in 0...noOfTilesInAColumn - 1
        {
            for j in 0...noOfTilesInARow - 1
            {
                gameBaseTile = self.createBackgroundTile()
                gameBaseTile.position.x = gameBaseTile.position.x + CGFloat(j * 30)
                gameBaseTile.position.y = gameBaseTile.position.y + CGFloat(i * 30)
                gameBase.addChild(gameBaseTile)
            }
        }
        self.addChild(gameBase)
        
    }
    
    func createBackgroundTile() -> SKShapeNode
    {
        let tile = SKShapeNode(rectOf: CGSize(width: 30.0, height: 30.0))
        tile.fillColor = UIColor.green
        tile.strokeColor = UIColor.red
        tile.position = CGPoint(x: 15, y: 15)
        tile.zPosition = 1
        return tile
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            let touchLocation = touch.location(in: self)
            print(touchLocation)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            let location = touch.location(in: self)
            
            if(controllerPressed){
                controllerMoved = true
                let v = CGVector(dx: location.x - base.position.x, dy: location.y - base.position.y)
                let angle = atan2(v.dy, v.dx)
                
                let length: CGFloat = base.frame.size.height / 5
                
                xDist = sin(angle - CGFloat(M_PI) / 2.0) * length
                yDist = cos(angle - CGFloat(M_PI) / 2.0) * length
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let touchLocation = touch.location(in: self)
            print(touchLocation)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let touchLocation = touch.location(in: self)
            print(touchLocation)
        }
    }
    
    func createController()
    {
        
        self.base = SKShapeNode(circleOfRadius: 50)
        self.base.fillColor = SKColor.darkGray
        self.base.position = CGPoint(x:100, y:70)
        self.base.alpha = 0.4
        self.base.zPosition = 3
        self.addChild(base)
        
        self.controller = SKShapeNode(circleOfRadius: 20)
        self.controller.fillColor = SKColor.gray
        self.controller.position = self.base.position
        self.controller.alpha = 0.7
        self.controller.zPosition = 4
        self.addChild(controller)
        
        self.speedController = SKSpriteNode(imageNamed: "fire")
        self.speedController.zPosition = 4
        self.speedController.alpha = 0.4
        self.speedController.position = CGPoint(x: screenWidth - 100, y: 70)
        self.speedController.setScale(0.4)
        self.addChild(speedController)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
