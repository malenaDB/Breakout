//
//  GameScene.swift
//  Breakout
//
//  Created by Malena on 1/6/21.
//  Copyright © 2021 MDB. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    let BallCategoryName = "ball"
    let PaddleCategoryName = "paddle"
    let BlockCategoryName = "block"
    var stuckButton = SKLabelNode()
    var ball = SKSpriteNode()
    var isFingerOnPaddle = false
    
    let BallCategory : UInt32 = 0x1 << 0
    let BottomCategory : UInt32 = 0x1 << 1
    let BlockCategory : UInt32 = 0x1 << 2
    let PaddleCategory : UInt32 = 0x1 << 3
    let BorderCategory : UInt32 = 0x1 << 4
    
    
    override func didMove(to view: SKView)
    {
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        ball = childNode(withName: BallCategoryName) as! SKSpriteNode
        ball.physicsBody!.applyImpulse(CGVector(dx: 2.0, dy: -2.0))
        
        let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        addChild(bottom)
        
        let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
        stuckButton = childNode(withName: "stuckButton") as! SKLabelNode

        bottom.physicsBody!.categoryBitMask = BottomCategory
        ball.physicsBody!.categoryBitMask = BallCategory
        paddle.physicsBody!.categoryBitMask = PaddleCategory
        borderBody.categoryBitMask = BorderCategory
        
        ball.physicsBody?.contactTestBitMask = BottomCategory | BlockCategory
        
        physicsWorld.contactDelegate = self
    
        createBlocks()
    }
    
    func createBlocks() {
        // create blocks programmaticcally so that you can add blocks and difficulty
        let numberOfBlocks = 8
        let blockWidth = SKSpriteNode(imageNamed: "blockimage").size.width
        let totalBlockWidth = blockWidth * CGFloat(numberOfBlocks)
        
        print(blockWidth)
        
        let xOffSet = (frame.width - totalBlockWidth) / 2
        
        for i in 0..<numberOfBlocks {
            let block = SKSpriteNode(imageNamed: "blockimage")
            block.position = CGPoint(x: xOffSet + CGFloat(CGFloat(i) + 0.5) * 60, y: frame.height * 0.8)
           // block.position = CGPoint(x: CGFloat(60 * i), y: frame.height * 0.8)
            block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
            block.physicsBody!.allowsRotation = false
            block.physicsBody!.friction = 0.0
            block.physicsBody!.affectedByGravity = false
            block.physicsBody!.isDynamic = false
            block.name = BlockCategoryName
            block.physicsBody!.categoryBitMask = BlockCategory
            block.zPosition = 1
            addChild(block)
        }
    }
      
    func breakBlock(node: SKNode)
    {
        node.removeFromParent()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        
        if let body = physicsWorld.body(at: touchLocation)
        {
            if body.node!.name == PaddleCategoryName
            {
                isFingerOnPaddle = true
            }
        }
        
        if stuckButton.frame.contains(touchLocation)
        {
            ball.physicsBody!.applyImpulse(CGVector(dx: 2.0, dy: -2.0))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if isFingerOnPaddle
        {
            let touch = touches.first
            let touchLocation = touch!.location(in: self)
            let previousLocation = touch!.previousLocation(in: self)
            let paddle = childNode(withName: PaddleCategoryName) as! SKSpriteNode
            
            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
            paddleX = max(paddleX, paddle.size.width/2)
            paddleX = min(paddleX, size.width - paddle.size.width/2)
            
            paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        isFingerOnPaddle = false
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            secondBody = contact.bodyA
            firstBody = contact.bodyB
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory
        {
            print("Hit Bottom.  First Contact Has Been Made.")
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory
        {
            print("Hit block.  Let's remove the block.")
            breakBlock(node: secondBody.node!)
        }
    }
}
