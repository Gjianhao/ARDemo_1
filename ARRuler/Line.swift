//
//  Line.swift
//  ARRuler
//
//  Created by gjh on 2017/12/7.
//  Copyright © 2017年 Gjianhao. All rights reserved.
//

import ARKit

enum LengthUnit {
    case meter, cenitMeter, inch
    
    var factor: Float {
        switch self {
        case .meter:
            return 1.0
        case .cenitMeter:
            return 100.0
        case .inch:
            return 39.3700787
        }
    }
    var name: String {
        switch self {
        case .meter:
            return "m"
        case .cenitMeter:
            return "cm"
        case .inch:
            return "inch"
        }
    }
}

class Line {
    var color = UIColor.brown
    var startNode : SCNNode
    var endNode : SCNNode
    var textNode : SCNNode
    var text : SCNText
    var lineNode : SCNNode?
    
    let sceneView: ARSCNView
    let startVector: SCNVector3
    let unit: LengthUnit
    
    init(sceneView: ARSCNView, startVector: SCNVector3, unit: LengthUnit) {
        self.sceneView = sceneView
        self.startVector = startVector
        self.unit = unit
        
        // 创建一个起始点
        let dot = SCNSphere(radius: 0.5)
        dot.firstMaterial?.diffuse.contents = color
        dot.firstMaterial?.lightingModel = .constant // 不会产生阴影
        dot.firstMaterial?.isDoubleSided = true  // 两面都光亮的球
        startNode = SCNNode(geometry: dot)
        startNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        startNode.position = startVector
        
        sceneView.scene.rootNode.addChildNode(startNode)
        
        // 结束点
        endNode = SCNNode(geometry: dot)
        endNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        // 线上面的字
        text = SCNText(string: "", extrusionDepth: 0.1)
        text.font = .systemFont(ofSize: 5)
        text.firstMaterial?.diffuse.contents = color
        text.firstMaterial?.lightingModel = .constant
        text.firstMaterial?.isDoubleSided = true
        text.alignmentMode = kCAAlignmentCenter
        text.truncationMode = kCATruncationMiddle // 文字过长,用...省略
        
        // 包装文字的节点
        let textWrapperNode = SCNNode(geometry: text)
        textWrapperNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        textNode = SCNNode()
        textNode.addChildNode(textWrapperNode)
        
        // 我们无法预期文字出现的位置,所以我们要给他来个约束,这个约束,把文字节点绑定在我们线的中间位置
        // SCNLookAtConstraint是一个约束,让它跟随我们设定的目标, 永远面向使用者
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
        constraint.isGimbalLockEnabled = true // 锁定
        textNode.constraints = [constraint]  // 添加约束
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
}
