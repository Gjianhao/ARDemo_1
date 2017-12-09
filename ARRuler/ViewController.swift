//
//  ViewController.swift
//  ARRuler
//
//  Created by gjh on 2017/12/5.
//  Copyright © 2017年 Gjianhao. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet var targetImageView: UIImageView!
    
    var session = ARSession()
    var configuration = ARWorldTrackingConfiguration()
    var isMeasuring = false // 正在测量吗  初始没有在测量状态
    
    var vectorZero = SCNVector3() // 原点
    var vectorStart = SCNVector3() // 起始点
    var vectorEnd = SCNVector3() // 结束点
    var lines = [Line]()
    var currentLine: Line?
    var unit = LengthUnit.cenitMeter // 默认单位公分 cm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.session = session
        infoLabel.text = "环境初始化中~"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration

        // Run the view's session, 移除所有的锚点,重新开始追踪
        session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        session.pause()
    }

    @IBAction func resetBtnClick(_ sender: UIButton) {
        for line in lines {
            line.remove()
        }
        lines.removeAll()
    }
    @IBAction func unitBtnClick(_ sender: UIButton) {
        
    }
    // 点击屏幕
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isMeasuring {
            isMeasuring = true
            reset()
            targetImageView.image = UIImage(named: "GreenTarget")
        } else {
            isMeasuring = false
            
            if let line = currentLine {
                lines.append(line)
                currentLine = nil
                targetImageView.image = UIImage(named: "WhiteTarget")
            }
        }
    }
    
    func reset() {
        vectorStart = SCNVector3()
        vectorEnd = SCNVector3()
    }
    
    // 扫描世界的方法(开始测量)
    func scanWorld() {
        // 拿到当前屏幕中点的位置
        guard let worldPosition = sceneView.worldVector(for: view.center) else { return }
        // 如果画面上一条线都没有
        if lines.isEmpty {
            infoLabel.text = "点击屏幕试试看"
        }
        // 如果现在开始测量
        if isMeasuring {
            // 设置开始节点
            if vectorStart == vectorZero {
                vectorStart = worldPosition // 把当前的位置设为开始节点
                currentLine = Line(sceneView: sceneView, startVector: vectorStart, unit: unit)
            }
            // 设置结束节点
            vectorEnd = worldPosition
            currentLine?.update(to: vectorEnd)
            infoLabel.text = currentLine?.distance(to: vectorEnd) ?? "..."
        }
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
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.scanWorld()
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
        infoLabel.text = "错误"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
        infoLabel.text = "中断"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
        infoLabel.text = "结束"
    }
}
