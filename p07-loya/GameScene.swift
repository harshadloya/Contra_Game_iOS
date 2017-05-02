//
//  GameScene.swift
//  p07-loya
//
//  Created by Harshad Loya on 4/20/17.
//  Copyright © 2017 Harshad Loya. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

var lives = 3
let bulletSound = SKAction.playSoundFileNamed("ShipBullet.wav", waitForCompletion: false)

let scaleup = SKAction.scale(to: 1.2, duration: 0.1)
let scaledown = SKAction.scale(to: 0.7, duration: 0.1)
let opaque = SKAction.fadeAlpha(to: 1, duration: 0.1)
let trans = SKAction.fadeAlpha(to: 0.6, duration: 0.1)
let bouncybouncy = SKAction.sequence([scaleup, scaledown])
let fade = SKAction.sequence([opaque, trans])

struct PhyCat
{
    static let Player : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Enemy : UInt32 = 0x1 << 3
    static let Edge : UInt32 = 0x1 << 4
    static let Bullet : UInt32 = 0x1 << 5
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var enemy = SKSpriteNode()
    
    var collided = Bool()
    
    var map = JSTileMap()
    var ground = TMXObjectGroup()
    var edge = TMXObjectGroup()
    var canonTMX = TMXObjectGroup()
    
    var canon = SKSpriteNode()
    var canonArray = Array<SKSpriteNode>()
    
    var player1 = SKSpriteNode()
    var bullet = SKSpriteNode()
    var standRightFlag = Bool()
    var standLeftFlag = Bool()
    
    var screenWidth = CGFloat()
    var screenHeight = CGFloat()
    
    var gameBase = SKNode()
    var gameBaseTile = SKShapeNode()

    var noOfTilesInARow = Int()
    var noOfTilesInAColumn = Int()
    
    var base = SKShapeNode()
    var controller = SKShapeNode()
    var speedController = SKSpriteNode()
    var jumpController = SKSpriteNode()
    var jumpControllerPressed = Bool()
    var controllerPressed = Bool()
    var controllerMoved = Bool()
    var speedControllerPressed = Bool()
    var speedBooster = CGFloat()
    
    var xDist = CGFloat()
    var yDist = CGFloat()
    
    var standRight = SKAction()
    var standLeft = SKAction()
    
    var aimUpAngleRight = SKAction()
    var aimUpAngleRightFlag = Bool()
    
    var aimDownAngleRight = SKAction()
    var aimDownAngleRightFlag = Bool()
    
    var runRight = SKAction()
    var runRightFlag = Bool()
    
    var jumpRight = SKAction()
    var jumpRightFlag = Bool()
    
    var lieDownRight = SKAction()
    var lieDownRightFlag = Bool()
    
    var aimUpAngleLeft = SKAction()
    var aimUpAngleLeftFlag = Bool()
    
    var aimDownAngleLeft = SKAction()
    var aimDownAngleLeftFlag = Bool()
    
    var runLeft = SKAction()
    var runLeftFlag = Bool()
    
    var jumpLeft = SKAction()
    var jumpLeftFlag = Bool()
    
    var lieDownLeft = SKAction()
    var lieDownLeftFlag = Bool()
    
    var aimUpLeft = SKAction()
    var aimUpLeftFlag = Bool()
    
    var aimUpRight = SKAction()
    var aimUpRightFlag = Bool()
    
    var killLeftAction = SKAction()
    var killRightAction = SKAction()
    
    var backgroundMusic = AVAudioPlayer()
    
    var camPanScale = CGFloat()
    var cam = SKCameraNode()
    
    var previousCamPosition = CGPoint()
    
    
    override func didMove(to view: SKView)
    {
        self.view?.isMultipleTouchEnabled = true
        self.physicsWorld.contactDelegate = self
        screenWidth = self.frame.size.width
        screenHeight = self.frame.size.height
        
        collided = false
        
        self.createBackgroundTile()
        
        self.addChild(map)
        
        ground = map.groupNamed("ground")
        
        player1 = self.createPlayer()
        map.addChild(player1)
        
        self.createController()
        
        self.createEnemyFromRight()
        
        self.createPhysicsAssets()
        
        cam.position = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
        cam.setScale(0.55)
        self.camera = cam
        map.addChild(cam)
        
        self.playBackgroundMusic(fileNamed: "contra_stage1.wav")
        
        let spawn = SKAction.run{
            () in
            
            let number = arc4random_uniform(3)
            print(number)
            if(number == 0){
                self.createEnemyFromRight()
            }
            if(number == 1){
                self.createEnemyFromLeft()
            }
            if(number == 2){
                self.createEnemyFromLeft()
                self.createEnemyFromRight()
            }
        }
        let delay = SKAction.wait(forDuration:7, withRange: 5)
        let SpawnDelay = SKAction.sequence([spawn, delay])
        let SpawnDelayForever = SKAction.repeatForever(SpawnDelay)
        self.run(SpawnDelayForever)
        
    }
    
    //Loads the level map from the tmx file
    func createBackgroundTile()
    {
        map = JSTileMap(named: "lvl1.tmx")
        map.position = CGPoint(x: 0, y: 0)
        map.setScale(2)
        
    }
    
    func playBackgroundMusic(fileNamed: String)
    {
        let loadTrack = Bundle.main.url(forResource: fileNamed, withExtension: nil)
        
        guard let track = loadTrack else
        {
            print("File named \(fileNamed) not found")
            return
        }
        
        do
        {
            backgroundMusic =  try AVAudioPlayer(contentsOf: track)
            backgroundMusic.numberOfLoops = -1
            backgroundMusic.prepareToPlay()
            backgroundMusic.play()
        }
        catch let error as NSError
        {
            print(error.description)
        }
    }
    
    func createPlayer() -> SKSpriteNode
    {
        //initialization of Actions for the Player
        self.playerRunRight()
        self.playerJumpRight()
        self.playerLyingRight()
        self.playerAimUpAngleRight()
        self.playerAimUpRight()
        self.playerAimDownAngleRight()
        self.playerStandRight()
        self.playerKillRight()
        
        self.playerStandLeft()
        self.playerRunLeft()
        self.playerJumpLeft()
        self.playerLyingLeft()
        self.playerAimUpAngleLeft()
        self.playerAimUpLeft()
        self.playerKillLeft()
        
        //creating the player
        let player = SKSpriteNode(imageNamed: "stand-right")
        standRightFlag = true
        collided = false
        player.position = CGPoint(x: self.frame.size.width / 6, y: self.frame.size.height / 3)
        player.zPosition = -60
        player.size = CGSize(width: 18, height:36)
        player.setScale(1.0)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.categoryBitMask = PhyCat.Player
        player.physicsBody?.collisionBitMask = PhyCat.Ground | PhyCat.Edge
        player.physicsBody?.contactTestBitMask = PhyCat.Enemy
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false
        
        player.run(SKAction.repeat(SKAction.sequence([SKAction.fadeOut(withDuration: 0.14),SKAction.fadeIn(withDuration: 0.14)]), count: 10))
        
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
        
        for z in 0...groundArrayObjects.count-1
        {
            groundDictObj = groundArrayObjects.object(at: z) as! NSDictionary
            groundX = groundDictObj.value(forKey: "x") as! CGFloat
            groundY = groundDictObj.value(forKey: "y") as! CGFloat
            groundW = (groundDictObj.value(forKey: "width") as! NSString).doubleValue
            groundH = (groundDictObj.value(forKey: "height") as! NSString).doubleValue
            
            let groundNode = SKSpriteNode(color: SKColor.clear, size: CGSize(width: groundW, height: groundH + 8))
            groundNode.position = CGPoint(x: groundX, y: groundY)
            groundNode.zPosition = -60
            
            groundNode.physicsBody = SKPhysicsBody(rectangleOf: groundNode.size)
            groundNode.physicsBody?.isDynamic = false
            groundNode.physicsBody?.categoryBitMask = PhyCat.Ground
            groundNode.physicsBody?.collisionBitMask = PhyCat.Player | PhyCat.Enemy
            groundNode.physicsBody?.contactTestBitMask = 0
            
            map.addChild(groundNode)
        }
        
        canonTMX = map.groupNamed("canons")
        var canonArrayObjects = NSMutableArray()
        canonArrayObjects =  canonTMX.objects
        
        var canonDictObj = NSDictionary()
        var canonX = CGFloat()
        var canonY = CGFloat()
        
        for z in 0...canonArrayObjects.count-1
        {
            canonDictObj = canonArrayObjects.object(at: z) as! NSDictionary
            canonX = canonDictObj.value(forKey: "x") as! CGFloat
            canonY = canonDictObj.value(forKey: "y") as! CGFloat
            
            let canonNode = SKSpriteNode(imageNamed: "canon_1")
            canonNode.position = CGPoint(x: canonX + 18, y: canonY + 15)
            canonNode.zPosition = -60
            
            canonArray.append(canonNode)
            map.addChild(canonNode)
        }
        
        edge = map.groupNamed("Edges")
        
        var edgesArrayObjects = NSMutableArray()
        edgesArrayObjects =  edge.objects
        
        var edgeDictObj = NSDictionary()
        var edgeX = CGFloat()
        var edgeY = CGFloat()
        var edgeW = Double()
        var edgeH = Double()
        
        for zz in 0...edgesArrayObjects.count-1
        {
            edgeDictObj = edgesArrayObjects.object(at: zz) as! NSDictionary
            edgeX = edgeDictObj.value(forKey: "x") as! CGFloat
            edgeY = edgeDictObj.value(forKey: "y") as! CGFloat
            edgeW = (edgeDictObj.value(forKey: "width") as! NSString).doubleValue
            edgeH = (edgeDictObj.value(forKey: "height") as! NSString).doubleValue
            
            let edgeNode = SKSpriteNode(color: SKColor.clear, size: CGSize(width: edgeW + 5.0, height: edgeH + 100.0))
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
 //       bullet.position = CGPoint(x: player1.position.x + player1.size.width - 9, y: player1.position.y + 2)
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
        
       // let move = SKAction.moveTo(x: self.size.width*0.5,duration: 1.8)
       // let remove = SKAction.removeFromParent()
       // let fire = SKAction.sequence([bulletSound, move, remove])
       // bullet.run(fire)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            let touchLocation = touch.location(in: self)
            
            if(controller.contains(touchLocation))
            {
                controllerPressed = true
            }
            
            if speedController.contains(touchLocation)
            {
                firebullet()
                if(standRightFlag){
                    bullet.position = CGPoint(x: player1.position.x + player1.size.width - 9, y: player1.position.y + 5)
                    //let move = SKAction.moveTo(x: self.size.width*0.5,duration: 1.8)
                    let move = SKAction.moveBy(x: self.size.width, y: 0, duration: 8.0)
                    let remove = SKAction.removeFromParent()
                    let fire = SKAction.sequence([bulletSound, move, remove])
                    bullet.run(fire)
                    speedController.run(fade)
                    speedController.run(bouncybouncy)
                }
                
                if(standLeftFlag){
                    bullet.position = CGPoint(x: player1.position.x, y: player1.position.y + 5)
                    //let move = SKAction.moveTo(x: -self.size.width*0.5,duration: 1.8)
                    let move = SKAction.moveBy(x: -self.size.width, y: 0, duration: 8.0)
                    let remove = SKAction.removeFromParent()
                    let fire = SKAction.sequence([bulletSound, move, remove])
                    bullet.run(fire)
                    speedController.run(fade)
                    speedController.run(bouncybouncy)
                }
                
                if(aimUpRightFlag){
                    bullet.position = CGPoint(x: player1.position.x + player1.size.width - 9, y: player1.position.y + 5)
                    let move = SKAction.moveBy(x: self.size.width, y: self.size.width, duration: 8.0)
                    let remove = SKAction.removeFromParent()
                    let fire = SKAction.sequence([bulletSound, move, remove])
                    bullet.run(fire)
                    speedController.run(fade)
                    speedController.run(bouncybouncy)
                }
                if(aimUpLeftFlag){
                    bullet.position = CGPoint(x: player1.position.x, y: player1.position.y + 5)
                    let move = SKAction.moveBy(x: -self.size.width, y: self.size.width, duration: 8.0)
                    let remove = SKAction.removeFromParent()
                    let fire = SKAction.sequence([bulletSound, move, remove])
                    bullet.run(fire)
                    speedController.run(fade)
                    speedController.run(bouncybouncy)
                }
                
                if(aimDownAngleRightFlag){
                    bullet.position = CGPoint(x: player1.position.x + player1.size.width - 9, y: player1.position.y + 5)
                    let move = SKAction.moveBy(x: self.size.width, y: -self.size.width, duration: 8.0)
                    let remove = SKAction.removeFromParent()
                    let fire = SKAction.sequence([bulletSound, move, remove])
                    bullet.run(fire)
                    speedController.run(fade)
                    speedController.run(bouncybouncy)
                }
                
                if(aimDownAngleLeftFlag){
                    bullet.position = CGPoint(x: player1.position.x, y: player1.position.y + 5)
                    let move = SKAction.moveBy(x: -self.size.width, y: -self.size.width, duration: 8.0)
                    let remove = SKAction.removeFromParent()
                    let fire = SKAction.sequence([bulletSound, move, remove])
                    bullet.run(fire)
                    speedController.run(fade)
                    speedController.run(bouncybouncy)
                }
                
            }
            if jumpController.contains(touchLocation)
            {
                jumpController.run(fade)
                jumpController.run(bouncybouncy)
                //jump()
                player1.run(jumpRight)
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            let touchLocation = touch.location(in: self)
            
            if(controllerPressed)
            {
                controllerMoved = true
                
                standLeftFlag = false
                standRightFlag = false
                
                let v = CGVector(dx: touchLocation.x - base.position.x, dy: touchLocation.y - base.position.y)
                let angle = atan2(v.dy, v.dx)
                
                let length: CGFloat = base.frame.size.height / 5
                
                xDist = sin(angle - .pi / 2.0) * length
                yDist = cos(angle - .pi / 2.0) * length
                
                //print(angle)
                controller.position = CGPoint(x:base.position.x - xDist, y:base.position.y + yDist)
                
                if(angle < 1.5 && angle >= 1.3)
                {
                    player1.size = CGSize(width: 18, height:36)
                    player1.run(SKAction.repeatForever(aimUpRight))
                    aimUpRightFlag = true
                    print("aiming up")
                }
                else{
                    aimUpRightFlag = false
                }
                
                if(angle < 1.3 && angle >= 0.4){
                    player1.size = CGSize(width: 18, height:36)
                    player1.run(SKAction.repeatForever(aimUpAngleRight))
                    aimUpAngleRightFlag = true
                    print("aim up angle right!")
                }
                else{
                    aimUpAngleRightFlag = false
                }
                
                if(angle < 0.4 && angle >= -0.2){
                    player1.size = CGSize(width: 18, height:36)
                    player1.run(SKAction.repeatForever(runRight))
                    runRightFlag = true
                    print("run right!")
                }
                else{
                    runRightFlag = false
                }
                
                if(angle < -0.2 && angle >= -1.1){
                    player1.size = CGSize(width: 18, height:36)
                    player1.run(SKAction.repeatForever(aimDownAngleRight))
                    aimDownAngleRightFlag = true
                    print("down angle right")
                }
                else{
                    aimDownAngleRightFlag = false
                }
                
                if(angle < -1.1 && angle >= -1.5)
                {
                    player1.size = CGSize(width: 36, height:18)
                    player1.run(SKAction.repeatForever(lieDownRight))
                    lieDownRightFlag = true
                    print("lying down")
                }
                else{
                    lieDownRightFlag = false
                }
////////////////////////////////
                
                if(angle < 1.7 && angle >= 1.5)
                {
                    player1.size = CGSize(width: 18, height:36)
                    player1.run(SKAction.repeatForever(aimUpLeft))
                    aimUpLeftFlag = true
                    print("aiming up")
                }
                else{
                    aimUpLeftFlag = false
                }
                
                if(angle < 2.8 && angle >= 1.7){
                    player1.size = CGSize(width: 18, height:36)
                    player1.run(SKAction.repeatForever(aimUpAngleLeft))
                    aimUpAngleLeftFlag = true
                    print("aim up angle Left!")
                }
                else{
                    aimUpAngleLeftFlag = false
                }
                
                if(angle >= 2.8 || angle <= -3.1){
                    player1.size = CGSize(width: 18, height:36)
                    player1.run(SKAction.repeatForever(runLeft))
                    runLeftFlag = true
                    print("run Left!")
                }
                else{
                    runLeftFlag = false
                }
                
                if(angle < -1.7 && angle > -3.1){
                    player1.size = CGSize(width: 18, height:36)
                    player1.run(SKAction.repeatForever(aimDownAngleLeft))
                    aimDownAngleLeftFlag = true
                    print("down angle left")
                }
                else{
                    aimDownAngleLeftFlag = false
                }
                
                if(angle < -1.5 && angle >= -1.7)
                {
                    player1.size = CGSize(width: 36, height:18)
                    player1.run(SKAction.repeatForever(lieDownLeft))
                    lieDownLeftFlag = true
                    print("lying down left")
                }
                else{
                    lieDownLeftFlag = false
                }
            }
            
            if speedController.contains(touchLocation)
            {
                firebullet()
                speedController.run(fade)
                speedController.run(bouncybouncy)
            }
            if jumpController.contains(touchLocation)
            {
                jumpController.run(fade)
                jumpController.run(bouncybouncy)
                //jump()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            
            let touchLocation = touch.location(in: self)
            if(controllerPressed)
            {
                if(runRightFlag || aimDownAngleRightFlag || aimUpAngleRightFlag || lieDownRightFlag || aimUpRightFlag){
                    player1.size = CGSize(width: 18, height:36)
                    standRightFlag = true
                    player1.run(SKAction.repeatForever(standRight))
                }
                
                if(runLeftFlag || aimDownAngleLeftFlag || aimUpAngleLeftFlag || lieDownLeftFlag || aimUpLeftFlag){
                    player1.size = CGSize(width: 18, height:36)
                    standLeftFlag = true
                    player1.run(SKAction.repeatForever(standLeft))
                }
                
                controller.position = base.position
                controllerPressed = false
                runRightFlag = false
                aimUpAngleRightFlag = false
                aimDownAngleRightFlag = false
                
                runLeftFlag = false
                aimUpAngleLeftFlag = false
                aimDownAngleLeftFlag = false
                
            }
            
            if speedController.contains(touchLocation)
            {
                firebullet()
                speedController.run(fade)
                speedController.run(bouncybouncy)
            }
            if jumpController.contains(touchLocation)
            {
                jumpController.run(fade)
                jumpController.run(bouncybouncy)
                //jump()
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
        
        self.speedController = SKSpriteNode(imageNamed: "o")
        self.speedController.zPosition = 4
        self.speedController.alpha = 0.6
        self.speedController.position = CGPoint(x: screenWidth * 0.90, y: 85)
        self.speedController.setScale(0.7)
        self.addChild(speedController)
        
        self.jumpController = SKSpriteNode(imageNamed: "x")
        self.jumpController.zPosition = 4
        self.jumpController.alpha = 0.6
        self.jumpController.position = CGPoint(x: screenWidth * 0.83, y: 52)
        self.jumpController.setScale(0.7)
        self.addChild(jumpController)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if(runRightFlag || aimDownAngleRightFlag || aimUpAngleRightFlag){
            player1.position = CGPoint(x: player1.position.x + 2, y: player1.position.y)
        }
        
        if(runLeftFlag || aimDownAngleLeftFlag || aimUpAngleLeftFlag){
            player1.position = CGPoint(x: player1.position.x - 2, y: player1.position.y)
        }
        
        previousCamPosition.x = cam.position.x
        
        cam.position.x = player1.position.x + 100
        cam.position.y = player1.position.y - 25
        
        if cam.position.x > previousCamPosition.x
        {
            controller.position.x += 4
            base.position.x += 4
            speedController.position.x += 4
            jumpController.position.x += 4
        }
        
        for i in 0...canonArray.count - 1{
            let location = player1.position
            
            //Aim
            let dx = location.x - canonArray[i].position.x
            let dy = location.y - canonArray[i].position.y
            let angle = atan2(dy, dx)
            
            if(angle <= 2.9 && angle > 2.8){
                canonArray[i].texture = SKTexture(imageNamed: "canon_1")
            }
            if(angle <= 2.8 && angle > 0.4){
                canonArray[i].texture = SKTexture(imageNamed: "canon_2")
            }
            if(angle <= 2.1 && angle > 1.1){
                canonArray[i].texture = SKTexture(imageNamed: "canon_3")
            }
            if(angle <= 1.1){
                canonArray[i].texture = SKTexture(imageNamed: "canon_4")
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        if ((firstBody.categoryBitMask == PhyCat.Bullet && secondBody.categoryBitMask == PhyCat.Enemy)||(firstBody.categoryBitMask == PhyCat.Enemy && secondBody.categoryBitMask == PhyCat.Bullet))
        {
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
        }
        
        if(collided==false)
        {
            if((firstBody.categoryBitMask == PhyCat.Player && secondBody.categoryBitMask == PhyCat.Enemy)||(firstBody.categoryBitMask == PhyCat.Enemy && secondBody.categoryBitMask == PhyCat.Player))
            {
                print("contact physics")
                //player1.removeAllActions()
                //player1.run(killRightAction)
                player1.run(SKAction.sequence([killRightAction, SKAction.removeFromParent()]))
                collided = true
                if(lives >= 1){
                    player1 = self.createPlayer()
                    map.addChild(player1)
                    lives -= 1
                    
                    self.base.removeFromParent()
                    self.controller.removeFromParent()
                    self.jumpController.removeFromParent()
                    self.speedController.removeFromParent()
                    
                    self.createController()
                }
                else
                {
                    gameover()
                }
            }
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
    
    func playerStandRight() {
        let f0 = SKTexture.init(imageNamed: "stand-right")
        let frames: [SKTexture] = [f0]
        standRight = SKAction.animate(with: frames, timePerFrame: 0.2)
    }
    
    func playerStandLeft() {
        let f0 = SKTexture.init(imageNamed: "stand-left")
        let frames: [SKTexture] = [f0]
        standLeft = SKAction.animate(with: frames, timePerFrame: 0.2)
    }
    
    func playerRunRight() {
        let f0 = SKTexture.init(imageNamed: "runright-frame1")
        let f1 = SKTexture.init(imageNamed: "runright-frame2")
        let f2 = SKTexture.init(imageNamed: "runright-frame3")
        let f3 = SKTexture.init(imageNamed: "runright-frame4")
        let f4 = SKTexture.init(imageNamed: "runright-frame5")
        let f5 = SKTexture.init(imageNamed: "runright-frame6")
        let frames: [SKTexture] = [f0, f1, f2, f3, f4, f5]
        runRight = SKAction.animate(with: frames, timePerFrame: 0.16)
    }
    
    func playerAimUpAngleRight() {
        let f0 = SKTexture.init(imageNamed: "runupright-frame1")
        let f1 = SKTexture.init(imageNamed: "runupright-frame2")
        let f2 = SKTexture.init(imageNamed: "runupright-frame3")
        let frames: [SKTexture] = [f0, f1, f2]
        aimUpAngleRight = SKAction.animate(with: frames, timePerFrame: 0.16)
    }
    
    func playerAimDownAngleRight() {
        let f0 = SKTexture.init(imageNamed: "rundownright-frame1")
        let f1 = SKTexture.init(imageNamed: "rundownright-frame2")
        let f2 = SKTexture.init(imageNamed: "rundownright-frame3")
        let frames: [SKTexture] = [f0, f1, f2]
        aimDownAngleRight = SKAction.animate(with: frames, timePerFrame: 0.16)
    }
    
    func playerJumpRight() {
        var jumpRightTexture = SKTextureAtlas()
        var jumpRightArray = [SKTexture]()
      
        jumpRightTexture = SKTextureAtlas(named: "jump-right.atlas")
        print(jumpRightTexture.textureNames.count)
        for i in 0...jumpRightTexture.textureNames.count - 1
        {
            let Name = "frame_\(i)_delay-0.02s.png"
            jumpRightArray.append(SKTexture(imageNamed: Name))
        }
        jumpRight = SKAction.animate(with: jumpRightArray, timePerFrame: 0.05)
    }
    
    func playerJumpLeft()
    {
        var jumpLeftTexture = SKTextureAtlas()
        var jumpLeftArray = [SKTexture]()
        
        jumpLeftTexture = SKTextureAtlas(named: "jump-right.atlas")
        print(jumpLeftTexture.textureNames.count)
        for i in 0...jumpLeftTexture.textureNames.count - 1
        {
            let Name = "frame_\(i)_delay-0.02s.png"
            jumpLeftArray.append(SKTexture(imageNamed: Name))
        }
        jumpLeft = SKAction.animate(with: jumpLeftArray, timePerFrame: 0.05)
    }
    
    func playerKillRight()
    {
        var killRight = SKTextureAtlas()
        var killRightArray = [SKTexture]()
        
        killRight = SKTextureAtlas(named: "killRight.atlas")
        for i in 1...killRight.textureNames.count
        {
            let Name = "killRight-frame\(i).png"
            killRightArray.append(SKTexture(imageNamed: Name))
        }
        killRightAction = SKAction.animate(with: killRightArray, timePerFrame: 0.16)
    }
    
    func createEnemyFromRight(){
        
        self.enemy = SKSpriteNode(imageNamed: "EnemyL1")
        self.enemy.position = CGPoint(x: self.frame.size.width + 50, y: self.frame.size.height / 2)
        self.enemy.zPosition = -60
        self.enemy.setScale(1.0)
        
        self.enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        self.enemy.physicsBody?.affectedByGravity = true
        self.enemy.physicsBody?.categoryBitMask = PhyCat.Enemy
        self.enemy.physicsBody?.collisionBitMask = PhyCat.Ground | PhyCat.Edge
        self.enemy.physicsBody?.contactTestBitMask = PhyCat.Player
        self.enemy.physicsBody?.isDynamic = true
        self.enemy.physicsBody?.allowsRotation = false
        
        var enemyFromRight = SKTextureAtlas()
        var enemyFromRightArray = [SKTexture]()
        
        enemyFromRight = SKTextureAtlas(named: "EnemyL.atlas")
        for i in 1...enemyFromRight.textureNames.count
        {
            let Name = "EnemyL\(i).png"
            enemyFromRightArray.append(SKTexture(imageNamed: Name))
        }
        self.enemy.run(SKAction.repeatForever(SKAction.animate(with: enemyFromRightArray, timePerFrame: 0.16)))
        self.enemy.run(SKAction.sequence([SKAction.move(to: CGPoint(x: -self.frame.size.width + 50, y: 0), duration: 30), SKAction.removeFromParent()]))
        print("adding enemy")
        map.addChild(self.enemy)
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
        runLeft = SKAction.animate(with: frames, timePerFrame: 0.16)
    }
    
    func playerAimUpAngleLeft() {
        let f0 = SKTexture.init(imageNamed: "runupleft-frame1")
        let f1 = SKTexture.init(imageNamed: "runupleft-frame2")
        let f2 = SKTexture.init(imageNamed: "runupleft-frame3")
        let frames: [SKTexture] = [f0, f1, f2]
        aimUpAngleLeft = SKAction.animate(with: frames, timePerFrame: 0.16)
    }
    
    func playerAimDownAngleLeft() {
        let f0 = SKTexture.init(imageNamed: "rundownleft-frame1")
        let f1 = SKTexture.init(imageNamed: "rundownleft-frame2")
        let f2 = SKTexture.init(imageNamed: "rundownleft-frame3")
        let frames: [SKTexture] = [f0, f1, f2]
        aimDownAngleLeft = SKAction.animate(with: frames, timePerFrame: 0.16)
    }
    
    func playerKillLeft()
    {
        var killLeft = SKTextureAtlas()
        var killLeftArray = [SKTexture]()
        
        killLeft = SKTextureAtlas(named: "killLeft.atlas")
        for i in 1...killLeft.textureNames.count
        {
            let Name = "killLeft-frame\(i).png"
            killLeftArray.append(SKTexture(imageNamed: Name))
        }
        killLeftAction = SKAction.animate(with: killLeftArray, timePerFrame: 0.16)
    }
    
    
    func createEnemyFromLeft(){
        
        self.enemy = SKSpriteNode(imageNamed: "EnemyR1")
        self.enemy.position = CGPoint(x: -300, y: self.frame.size.height / 2)
        self.enemy.zPosition = -60
        self.enemy.setScale(1.0)
        
        self.enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        self.enemy.physicsBody?.affectedByGravity = true
        self.enemy.physicsBody?.categoryBitMask = PhyCat.Enemy
        self.enemy.physicsBody?.collisionBitMask = PhyCat.Ground | PhyCat.Edge
        self.enemy.physicsBody?.contactTestBitMask = PhyCat.Player
        self.enemy.physicsBody?.isDynamic = true
        self.enemy.physicsBody?.allowsRotation = false
        
        var enemyFromRight = SKTextureAtlas()
        var enemyFromRightArray = [SKTexture]()
        
        enemyFromRight = SKTextureAtlas(named: "EnemyR.atlas")
        for i in 1...enemyFromRight.textureNames.count
        {
            let Name = "EnemyR\(i).png"
            enemyFromRightArray.append(SKTexture(imageNamed: Name))
        }
        self.enemy.run(SKAction.repeatForever(SKAction.animate(with: enemyFromRightArray, timePerFrame: 0.16)))
        self.enemy.run(SKAction.sequence([SKAction.move(to: CGPoint(x: self.frame.size.width + 50, y: 0), duration: 30), SKAction.removeFromParent()]))
        print("adding enemy")
        map.addChild(self.enemy)
    }
    
    func gameover() {
        let toScene = GameOver(size: (view?.bounds.size)!)
        toScene.scaleMode = self.scaleMode
        let move = SKTransition.fade(withDuration: 1)
        self.view!.presentScene(toScene, transition: move)
    }

}
