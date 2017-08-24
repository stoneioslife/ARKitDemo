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

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, UIGestureRecognizerDelegate {

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
        
        let tap = UITapGestureRecognizer(target: self, action: Selector(("handleTap:")))
        
        sceneView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureSession()
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
    
    func configureSession()  {
        if ARWorldTrackingConfiguration.isSupported {
            
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
            
            sceneView.session.run(configuration)
        
        } else {
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            
            // Run the view's session
            sceneView.session.run(configuration)
            
        }
    }
    
    func addNewShip()  {
        let cubeNode = Ship()
        
        let posX = floatBetween(-0.5, 0.5)
        let posY = floatBetween(-0.5, 0.5)
        
        cubeNode.position = SCNVector3(posX,posY,-1)
        
        sceneView.scene.rootNode.addChildNode(cubeNode)
    }
    
    //MARK: - Actions
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        
        self.playSoundEffect(ofType: .torpedo)
        
        let bulletsNode = Bullet()
        
        let (direction, position) = self.getUserVector()
        
        bulletsNode.position = position
        
        let bulletDirection = direction
        bulletsNode.physicsBody?.applyForce(bulletDirection, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletsNode)
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        //print("did begin contact", contact.nodeA.physicsBody!.categoryBitMask, contact.nodeB.physicsBody!.categoryBitMask)
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.ship.rawValue || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.ship.rawValue { // this conditional is not required--we've used the bit masks to ensure only one type of collision takes place--will be necessary as soon as more collisions are created/enabled
            
            print("Hit ship!")
            self.removeNodeWithAnimation(contact.nodeB, explosion: false) // remove the bullet
            self.userSocre += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { // remove/replace ship after half a second to visualize collision
                self.removeNodeWithAnimation(contact.nodeA, explosion: true)
                self.addNewShip()
            })
            
        }
    }
    
    func removeNodeWithAnimation(_ node: SCNNode, explosion: Bool) {
        
        // Play collision sound for all collisions (bullet-bullet, etc.)
        
        self.playSoundEffect(ofType: .collision)
        
        if explosion {
            
            // Play explosion sound for bullet-ship collisions
            
            self.playSoundEffect(ofType: .explosion)
            
            let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: nil)
            let systemNode = SCNNode()
            systemNode.addParticleSystem(particleSystem!)
            // place explosion where node is
            systemNode.position = node.position
            sceneView.scene.rootNode.addChildNode(systemNode)
        }
        
        // remove node
        node.removeFromParentNode()
    }
    
    func playSoundEffect(ofType effect: SoundEffect) {
        
        DispatchQueue.main.async {
            do
            {
                if let effectURL = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3") {
                    
                    self.player = try AVAudioPlayer(contentsOf: effectURL)
                    self.player.play()
                    
                }
            } catch let error as NSError {
                print(error.description)
            }
        }
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) {
        
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
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

enum SoundEffect: String {
    case explosion = "explosion"
    case collision = "collision"
    case torpedo = "torpedo"
}

