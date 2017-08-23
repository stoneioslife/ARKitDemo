//
//  Ship.swift
//  StoneARDemo
//
//  Created by stone on 2017/8/23.
//  Copyright © 2017年 NgariHealth. All rights reserved.
//

import UIKit
import SceneKit

class Ship: SCNNode {
    override init() {
        super.init()
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0);
        self.geometry = box;
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape);
        self.physicsBody?.isAffectedByGravity = false
        
        self.physicsBody?.categoryBitMask = CollisionCategory.ship.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.bullets.rawValue
        
        let material = SCNMaterial();
        material.diffuse.contents = UIImage(named: "galaxy")
        self.geometry?.materials = [material,material,material,material,material]
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
