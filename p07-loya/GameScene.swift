//
//  GameScene.swift
//  p07-loya
//
//  Created by Harshad Loya on 4/20/17.
//  Copyright © 2017 Harshad Loya. All rights reserved.
//

import SpriteKit
import GameplayKit
let bulletSound = SKAction.playSoundFileNamed("ShipBullet.wav", waitForCompletion: false)

struct PhyCat
{
    static let Player : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Enemy : UInt32 = 0x1 << 3
    static let Edge : UInt32 = 0x1 << 4
    static let Bullet : UInt32 = 0x1 << 5
}

class GameScene: SKScene
{
    
    var map = JSTileMap()
    var ground = TMXObjectGroup()
    var edge = TMXObjectGroup()
    
    var player1 = SKSpriteNode()
    var bullet = SKSpriteNode()
    
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
    
    var aimUpAngleRight = SKAction()
    var aimUpAngleRightFlag = Bool()
    
    var aimDownAngleRight = SKAction()
    var aimDownAngleRightFlag = Bool()
    
    var runRight = SKAction()
    var runRightFlag = Bool()
    
    var jumpRight = SKAction()
    var jumpRightFlag = Bool()
    
    var lieDownRight = SKAction()
    var aimUpRight = SKAction()
    
    var aimUpAngleLeft = SKAction()
    var aimUpAngleLeftFlag = Bool()
    
    var aimDownAngleLeft = SKAction()
    var aimDownAngleLeftFlag = Bool()
    
    var runLeft = SKAction()
    var runLeftFlag = Bool()
    
    var jumpLeft = SKAction()
    var jumpLeftFlag = Bool()
    
    var lieDownLeft = SKAction()
    var aimUpLeft = SKAction()
    
    override func didMove(to view: SKView)
    {
        screenWidth = self.frame.size.width
        screenHeight = self.frame.size.height
        
        self.createBackgroundTile()
        
        self.addChild(map)
        
        ground = map.groupNamed("ground")
        
        player1 = self.createPlayer()
        map.addChild(player1)
        
        self.createController()
        
        self.createPhysicsAssets()
        
    }
    
    //Loads the level map from the tmx file
    func createBackgroundTile()
    {
        map = JSTileMap(named: "lvl1.tmx")
        map.position = CGPoint(x: 0, y: 0)
        map.setScale(2)
        
    }
    
    func createPlayer() -> SKSpriteNode
    {
        
        self.playerRunRight()
        self.playerJumpRight()
        self.playerLyingRight()
        self.playerAimUpAngleRight()
        self.playerAimUpRight()
        self.playerAimDownAngleRight()
        
        self.playerRunLeft()
        self.playerJumpLeft()
        self.playerLyingLeft()
        self.playerAimUpAngleLeft()
        self.playerAimUpLeft()
        self.playerAimDownAngleLeft()
        
        let player = SKSpriteNode(imageNamed: "stand-right")
        player.position = CGPoint(x: self.frame.size.width / 6, y: self.frame.size.height / 3)
        player.zPosition = -60
        player.setScale(1.0)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 25, height: 25))
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.categoryBitMask = PhyCat.Player
        player.physicsBody?.collisionBitMask = PhyCat.Ground | PhyCat.Edge
        player.physicsBody?.contactTestBitMask = PhyCat.Enemy
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false
        
        return player
    }
    
    func createPhysicsAssets()
    {
        ground = map.groupNamed("ground")
        
        var groundArrayObjects = NSMutableArray()
        groundArrayObjects =  ground.objects
        
        var groundDictObj = NSDictionary()
        var groundX = CGFloat()
        var groundY = CGFloat()
        var groundW = Double()
        var groundH = Double()
        
        for var z in 0...groundArrayObjects.count-1
        {
            groundDictObj = groundArrayObjects.object(at: z) as! NSDictionary
            groundX = groundDictObj.value(forKey: "x") as! CGFloat
            groundY = groundDictObj.value(forKey: "y") as! CGFloat
            groundW = (groundDictObj.value(forKey: "width") as! NSString).doubleValue
            groundH = (groundDictObj.value(forKey: "height") as! NSString).doubleValue
            
            let groundNode = SKSpriteNode(color: SKColor.clear, size: CGSize(width: groundW, height: groundH + 25))
            groundNode.position = CGPoint(x: groundX, y: groundY)
            groundNode.zPosition = -60
            
            groundNode.physicsBody = SKPhysicsBody(rectangleOf: groundNode.size)
            groundNode.physicsBody?.isDynamic = false
            groundNode.physicsBody?.categoryBitMask = PhyCat.Ground
            groundNode.physicsBody?.collisionBitMask = PhyCat.Player | PhyCat.Enemy
            groundNode.physicsBody?.contactTestBitMask = 0
            
            map.addChild(groundNode)
        }
        
        edge = map.groupNamed("Edges")
        
        var edgesArrayObjects = NSMutableArray()
        edgesArrayObjects =  edge.objects
        
        var edgeDictObj = NSDictionary()
        var edgeX = CGFloat()
        var edgeY = CGFloat()
        var edgeW = Double()
        var edgeH = Double()
        
        for var zz in 0...edgesArrayObjects.count-1
        {
            edgeDictObj = edgesArrayObjects.object(at: zz) as! NSDictionary
            edgeX = edgeDictObj.value(forKey: "x") as! CGFloat
            edgeY = edgeDictObj.value(forKey: "y") as! CGFloat
            edgeW = (edgeDictObj.value(forKey: "width") as! NSString).doubleValue
            edgeH = (edgeDictObj.value(forKey: "height") as! NSString).doubleValue
            
            let edgeNode = SKSpriteNode(color: SKColor.clear, size: CGSize(width: edgeW, height: edgeH))
            edgeNode.position = CGPoint(x: edgeX, y: edgeY)
            edgeNode.zPosition = -60
            
            edgeNode.physicsBody = SKPhysicsBody(rectangleOf: edgeNode.size)
            edgeNode.physicsBody?.isDynamic = false
            edgeNode.physicsBody?.categoryBitMask = PhyCat.Edge
            edgeNode.physicsBody?.collisionBitMask = PhyCat.Player | PhyCat.Enemy
            edgeNode.physicsBody?.contactTestBitMask = PhyCat.Player | PhyCat.Enemy
            
            map.addChild(edgeNode)
        }
    }
    
    func firebullet()
    {
        bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.position = CGPoint(x: player1.position.x + player1.size.width - 9, y: player1.position.y + 2)
        bullet.setScale(0.8)
        bullet.zPosition = -61
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.height/2)
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.physicsBody?.categoryBitMask = PhyCat.Bullet
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.contactTestBitMask = PhyCat.Enemy
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.affectedByGravity = false
        map.addChild(bullet)
        
        let move = SKAction.moveTo(x: self.size.width*0.5,duration: 1.8)
        let remove = SKAction.removeFromParent()
        let fire = SKAction.sequence([bulletSound, move, remove])
        bullet.run(fire)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            let touchLocation = touch.location(in: self)
            if(controller.contains(touchLocation)){
                controllerPressed = true
            }
            if speedController.contains(touchLocation)
            {
                firebullet()
            }
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
                
                print(angle)
                controller.position = CGPoint(x:base.position.x - xDist, y:base.position.y + yDist)

                
                if(angle < 1.5 && angle >= 1.3)
                {
                    player1.run(aimUpRight)
                    aimUpAngleRightFlag = false
                    aimDownAngleRightFlag = false
                    runRightFlag = false
                    print("aiming up")
                }
                
                if(angle < 1.3 && angle >= 0.4){
                    player1.run(SKAction.repeatForever(aimUpAngleRight))
                    aimUpAngleRightFlag = true
                    //player1.run(SKAction.moveBy(x: 10, y: 0, duration: 2))
                    print("aim up angle right!")
                }
                else{
                    aimUpAngleRightFlag = false
                }
                
                if(angle < 0.4 && angle >= -0.2){
                    player1.run(runRight)
                    runRightFlag = true
                    print("run right!")
                }
                else{
                    runRightFlag = false
                }
                
                if(angle < -0.2 && angle >= -1.1){
                    player1.run(SKAction.repeatForever(aimDownAngleRight))
                    aimDownAngleRightFlag = true
                    print("down angle right")
                }
                else{
                    aimDownAngleRightFlag = false
                }
                
                if(angle < -1.1 && angle >= -1.5)
                {
                    player1.run(lieDownRight)
                    aimUpAngleRightFlag = false
                    aimDownAngleRightFlag = false
                    runRightFlag = false
                    print("lying down")
                }
////////////////////////////////
                /*
                if(angle < 1.7 && angle >= 1.5)
                {
                    player1.run(aimUpLeft)
                    aimUpAngleLeftFlag = false
                    aimDownAngleLeftFlag = false
                    runLeftFlag = false
                    print("aiming up")
                }
                
                if(angle < 2.8 || angle >= 1.7){
                    player1.run(aimUpAngleLeft)
                    aimUpAngleLeftFlag = true
                    //player1.run(SKAction.moveBy(x: 10, y: 0, duration: 2))
                    print("aim up angle Left!")
                }
                else{
                    aimUpAngleLeftFlag = false
                }
                
                if(angle < 2.8 && angle <= -3.1){
                    player1.run(runLeft)
                    runLeftFlag = true
                    print("run Left!")
                }
                else{
                    runLeftFlag = false
                }
                
                if(angle < -0.2 && angle >= -3.1){
                    player1.run(aimDownAngleLeft)
                    aimDownAngleLeftFlag = true
                    print("down angle right")
                }
                else{
                    aimDownAngleLeftFlag = false
                }
                
                if(angle < -1.1 && angle >= -1.5)
                {
                    player1.run(lieDownLeft)
                    aimUpAngleLeftFlag = false
                    aimDownAngleLeftFlag = false
                    runLeftFlag = false
                    print("lying down")
                }
*/
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let touchLocation = touch.location(in: self)
            if(controllerPressed){
                controller.position = base.position
                controllerPressed = false
                runRightFlag = false
                aimUpAngleRightFlag = false
                aimDownAngleRightFlag = false
                
                controllerPressed = false
                runLeftFlag = false
                aimUpAngleLeftFlag = false
                aimDownAngleLeftFlag = false
                
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let touchLocation = touch.location(in: self)
            if(controllerPressed)
            {
                print(touchLocation)
            }
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
        if(runRightFlag || aimDownAngleRightFlag || aimUpAngleRightFlag){
            player1.position = CGPoint(x: player1.position.x + 2, y: player1.position.y)
        }
        
        if(runLeftFlag || aimDownAngleLeftFlag || aimUpAngleLeftFlag){
            player1.position = CGPoint(x: player1.position.x - 2, y: player1.position.y)
        }
    }
    
    func playerLyingRight() {
        let f0 = SKTexture.init(imageNamed: "floorright-frame1")
        let frames: [SKTexture] = [f0]
        lieDownRight = SKAction.animate(with: frames, timePerFrame: 0.2)
    }

    func playerAimUpRight() {
        let f0 = SKTexture.init(imageNamed: "aimupright-frame1")
        let frames: [SKTexture] = [f0]
        aimUpRight = SKAction.animate(with: frames, timePerFrame: 0.2)
    }
    
    func playerRunRight() {
        let f0 = SKTexture.init(imageNamed: "runright-frame1")
        let f1 = SKTexture.init(imageNamed: "runright-frame2")
        let f2 = SKTexture.init(imageNamed: "runright-frame3")
        let f3 = SKTexture.init(imageNamed: "runright-frame4")
        let f4 = SKTexture.init(imageNamed: "runright-frame5")
        let f5 = SKTexture.init(imageNamed: "runright-frame6")
        let frames: [SKTexture] = [f0, f1, f2, f3, f4, f5]
        runRight = SKAction.animate(with: frames, timePerFrame: 0.2)
    }
    
    func playerAimUpAngleRight() {
        let f0 = SKTexture.init(imageNamed: "runupright-frame1")
        let f1 = SKTexture.init(imageNamed: "runupright-frame2")
        let f2 = SKTexture.init(imageNamed: "runupright-frame3")
        let frames: [SKTexture] = [f0, f1, f2]
        aimUpAngleRight = SKAction.animate(with: frames, timePerFrame: 0.2)
    }
    
    func playerAimDownAngleRight() {
        let f0 = SKTexture.init(imageNamed: "rundownright-frame1")
        let f1 = SKTexture.init(imageNamed: "rundownright-frame2")
        let f2 = SKTexture.init(imageNamed: "rundownright-frame3")
        let frames: [SKTexture] = [f0, f1, f2]
        aimDownAngleRight = SKAction.animate(with: frames, timePerFrame: 0.2)
    }
    
    func playerJumpRight() {
        let f0 = SKTexture.init(imageNamed: "jump-frame1")
        let f1 = SKTexture.init(imageNamed: "jump-frame2")
        let f2 = SKTexture.init(imageNamed: "jump-frame3")
        let f3 = SKTexture.init(imageNamed: "jump-frame4")
        let frames: [SKTexture] = [f0, f1, f2, f3]
        jumpRight = SKAction.animate(with: frames, timePerFrame: 0.05)
    }
    
    ////////////////////////////////////////
    func playerLyingLeft() {
        let f0 = SKTexture.init(imageNamed: "floorleft-frame1")
        let frames: [SKTexture] = [f0]
        lieDownLeft = SKAction.animate(with: frames, timePerFrame: 0.2)
    }
    
    func playerAimUpLeft() {
        let f0 = SKTexture.init(imageNamed: "aimupleft-frame1")
        let frames: [SKTexture] = [f0]
        aimUpLeft = SKAction.animate(with: frames, timePerFrame: 0.2)
    }
    
    func playerRunLeft() {
        let f0 = SKTexture.init(imageNamed: "runleft-frame1")
        let f1 = SKTexture.init(imageNamed: "runleft-frame2")
        let f2 = SKTexture.init(imageNamed: "runleft-frame3")
        let f3 = SKTexture.init(imageNamed: "runleft-frame4")
        let f4 = SKTexture.init(imageNamed: "runleft-frame5")
        let f5 = SKTexture.init(imageNamed: "runleft-frame6")
        let frames: [SKTexture] = [f0, f1, f2, f3, f4, f5]
        runLeft = SKAction.animate(with: frames, timePerFrame: 0.2)
    }
    
    func playerAimUpAngleLeft() {
        let f0 = SKTexture.init(imageNamed: "runupleft-frame1")
        let f1 = SKTexture.init(imageNamed: "runupleft-frame2")
        let f2 = SKTexture.init(imageNamed: "runupleft-frame3")
        let frames: [SKTexture] = [f0, f1, f2]
        aimUpAngleLeft = SKAction.animate(with: frames, timePerFrame: 0.2)
    }
    
    func playerAimDownAngleLeft() {
        let f0 = SKTexture.init(imageNamed: "rundownleft-frame1")
        let f1 = SKTexture.init(imageNamed: "rundownleft-frame2")
        let f2 = SKTexture.init(imageNamed: "rundownleft-frame3")
        let frames: [SKTexture] = [f0, f1, f2]
        aimDownAngleLeft = SKAction.animate(with: frames, timePerFrame: 0.2)
    }
    
    func playerJumpLeft() {
        let f0 = SKTexture.init(imageNamed: "jump-frame1")
        let f1 = SKTexture.init(imageNamed: "jump-frame2")
        let f2 = SKTexture.init(imageNamed: "jump-frame3")
        let f3 = SKTexture.init(imageNamed: "jump-frame4")
        let frames: [SKTexture] = [f0, f1, f2, f3]
        jumpLeft = SKAction.animate(with: frames, timePerFrame: 0.05)
    }
}
