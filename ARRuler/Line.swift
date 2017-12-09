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
    
    
    /// 一条线的初始化
    ///
    /// - Parameters:
    ///   - sceneView: 场景视图
    ///   - startVector: 开始节点位置
    ///   - unit: 单位
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
    // 更新文字和线的变化
    func update(to vector: SCNVector3) {
        lineNode?.removeFromParentNode() // 把所有的线给移除掉
        lineNode = startVector.line(to: vector, color: color) // 画一条线
        sceneView.scene.rootNode.addChildNode(lineNode!)
        
        // 更新文字
        text.string = distance(to: vector)
        // 设置文字的位置,放在线的中间
        textNode.position = SCNVector3((startVector.x + vector.x)/2.0, (startVector.y + vector.y)/2.0, (startVector.z + vector.z)/2.0)
        // 结束节点的位置,在手机移动了多少  他就在那里
        endNode.position = vector
        
        if endNode.parent == nil {
            sceneView.scene.rootNode.addChildNode(endNode)
        }
    }
    
    /// 得到距离的字符串形式
    ///
    /// - Parameter vector: 空间点的坐标
    /// - Returns: 长度
    func distance(to vector: SCNVector3) -> String {
        return String(format: "%0.2f %@", startVector.distance(from: vector) * unit.factor, unit.name)
    }
    
    func remove() {
        startNode.removeFromParentNode()
        endNode.removeFromParentNode()
        textNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
    }
    
    
}
