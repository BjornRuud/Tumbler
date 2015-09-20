//
//  GameScene.swift
//  Tumbler
//
//  Created by Bjørn Olav Ruud on 20.09.15.
//  Copyright (c) 2015 Bjørn Olav Ruud. All rights reserved.
//

import CoreMotion
import SpriteKit

enum Shape: Int {
    case Triangle
    case Square
    case Circle

    static let bounds = CGRect(x: 0, y: 0, width: 64, height: 64)

    static func randomShape() -> Shape {
        let randShape = Int.random(min: 0, max: Circle.rawValue)
        return Shape(rawValue: randShape)!
    }

    var path: CGMutablePathRef {
        let bounds = Shape.bounds
        let path = CGPathCreateMutable()
        switch self {
        case .Triangle:
            CGPathMoveToPoint(path, nil, 0, bounds.size.height)
            CGPathAddLineToPoint(path, nil, bounds.size.width, bounds.size.height)
            CGPathAddLineToPoint(path, nil, bounds.size.width / 2, 0)
            CGPathCloseSubpath(path)

        case .Square:
            CGPathAddRect(path, nil, bounds)

        case .Circle:
            CGPathAddEllipseInRect(path, nil, bounds)
        }

        return path
    }
}

class GameScene: SKScene {
    let gravity = 9.81
    let motionManager = CMMotionManager()

    override func didMoveToView(view: SKView) {
        // Use edges of screen as physics border
        backgroundColor = SKColor.blackColor()
        scaleMode = .AspectFit
        physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)

        // Start accelerometer
        motionManager.accelerometerUpdateInterval = 1.0 / 30.0
        motionManager.startAccelerometerUpdates()

        // Add some random shapes
        for _ in 1...10 {
            let position = CGPoint(x: Int.random(Int(view.bounds.size.width)),
                                   y: Int.random(Int(view.bounds.size.height)))
            addShapeAtPosition(position)
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(location)
            if touchedNode == self {
                // Node not found, add new
                addShapeAtPosition(location)
            }
            else {
                // Node found, remove it
                touchedNode.removeFromParent()
            }
        }
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        // Update gravity vector
        if let accelData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: CGFloat(accelData.acceleration.x * gravity),
                                            dy: CGFloat(accelData.acceleration.y * gravity))
        }
    }

    func addShapeAtPosition(pos: CGPoint) {
        let shape = Shape.randomShape()
        let node = SKShapeNode(path: shape.path, centered: true)
        node.fillColor = SKColor.whiteColor()
        let physicsBody: SKPhysicsBody
        switch shape {
        case .Triangle:
            physicsBody = SKPhysicsBody(polygonFromPath: node.path!)
        case .Square:
            physicsBody = SKPhysicsBody(rectangleOfSize: Shape.bounds.size)
        case .Circle:
            physicsBody = SKPhysicsBody(circleOfRadius: Shape.bounds.size.width / 2)
        }
        node.physicsBody = physicsBody

        node.position = pos
        addChild(node)
    }
}
