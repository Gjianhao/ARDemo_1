//
//  ViewController.swift
//  ARDemo_2
//
//  Created by gjh on 2017/11/17.
//  Copyright © 2017年 Gjianhao. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let textures = ["earth.jpg", "jupiter.jpg", "mars.jpg", "venus.jpg"]
    private var index = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        @IBAction func clickBtn(_ sender: Any) {
        }
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
//  ----------------------------------------------------------------------------
//        let scene = SCNScene()
//        /* 创建几何模型 */
//        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
//        /* 渲染 */
//        let material = SCNMaterial()
//        // 渲染延伸到全局
//        material.diffuse.contents = UIImage(named: "IMG_0244")
//        box.materials = [material]
//
//        /* 创建节点 */
//        let boxNode = SCNNode(geometry: box)
//        /* 设置节点的位置 */
//        boxNode.position = SCNVector3(0, 0, -0.2)
//        /* 将节点放在根节点上 */
//        scene.rootNode.addChildNode(boxNode)
//
//        sceneView.scene = scene
        
//  ----------------------------------------------------------------------------
        // 创建一个场景
        let scene = SCNScene()
        // 创建球型模型
        let sphere = SCNSphere(radius: 0.1)
        // 创建渲染器
        let material = SCNMaterial()
        // 设置渲染器延伸的内容
        material.diffuse.contents = UIImage(named: "earth")
        // 将渲染器添加到模型上
        sphere.materials = [material]
        // 创建节点,节点几何为模型
        let sphereNode = SCNNode(geometry: sphere)
        // 设置节点的位置
        sphereNode.position = SCNVector3(0, 0, -0.5)
        // 将节点设置为场景的根节点
        scene.rootNode.addChildNode(sphereNode)
        
        sceneView.scene = scene
        // 注册手势事件
        registerGestureRecognizers()
    }
    
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let sceneView = tapGestureRecognizer.view as! ARSCNView
        let touchLocation = tapGestureRecognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation, options: [:])
        
        if !hitResults.isEmpty {
            if index == textures.count {
                index = 0
            }
            
            guard let hitResult = hitResults.first else {
                return
            }
            
            let node = hitResult.node
            node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: textures[index])
            index += 1
            
        }
        
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
}
