//
//  ViewController.swift
//  StoneARDemo
//
//  Created by stone on 2017/8/23.
//  Copyright © 2017年 NgariHealth. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    var player: AVAudioPlayer!
    
    private var userSocre: Int = 0 {
        didSet{
            DispatchQueue.main.async {
                self.scoreLabel.text = String(self.userSocre)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = self;
        
        self.addNewShip()
        
        self.userSocre = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func addNewShip()  {
        let cubeNode = Ship()
        
        let posX = floatBetween(-0.5, 0.5)
        let posY = floatBetween(-0.5, 0.5)
        
        cubeNode.position = SCNVector3(posX,posY,-1)
        
        sceneView.scene.rootNode.addChildNode(cubeNode)
    }
    
    func floatBetween(_ first: Float, _ second: Float ) -> Float {
        return (Float(arc4random()) / Float(UInt32.max)) * (first - second) + second
    }
    
    
}

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let bullets  = CollisionCategory(rawValue: 1 << 0) // 00...01
    static let ship = CollisionCategory(rawValue: 1 << 1) // 00..10
}
