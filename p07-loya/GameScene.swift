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
        for touch in touches
        {
            let touchLocation = touch.location(in: self)
            print(touchLocation)
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
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
