//
//  SceneViewViewController.swift
//  SolarSystem
//
//  Created by gjh on 2017/11/19.
//  Copyright © 2017年 Gjianhao. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class SceneViewViewController: UIViewController, ARSCNViewDelegate {

    let sunNode = SCNNode()
    let moonNode = SCNNode()
    let earthNode = SCNNode()
    let earthGroupNode = SCNNode() // 地球和月球当做一个整体的节点,公转
    let moonRotationNode = SCNNode() //  月球绕地球转的节点
    let sunHaloNode = SCNNode() // 太阳光晕
    
    
    // 懒加载 arSession
    lazy var arSession : ARSession = {
        () -> ARSession in
        let arSession = ARSession()
        return arSession
    }()
    
    
    // 懒加载 arSCNView
    /* lazy var arSCNView : ARSCNView = {
        () -> ARSCNView in
//        var arSCNView = ARSCNView(frame: self.view.bounds)
        let arSCNView = ARSCNView()   // 不知道为啥写懒加载会崩,原因后续再看,所以先暂时不用懒加载了
        arSCNView.frame = view.bounds
        arSCNView.session = arSession
        arSCNView.automaticallyUpdatesLighting = true
        // 初始化节点
        initNode()
        return arSCNView
    }() */
    
    let arSCNView = ARSCNView()
    let arConfiguration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arSCNView.frame = view.bounds
        arSCNView.session = arSession
        // 自动调节亮度
        arSCNView.automaticallyUpdatesLighting = true
        // 初始化节点
        initNode()
        // 太阳自转
        sunRotation()
        // 地球自转和月球围绕地球转
        earthTurn()
        // 地球公转
        earthRotation()
        
        view.addSubview(arSCNView)
        arSCNView.delegate = self
        arSCNView.showsStatistics = true        
    }

    override func viewWillAppear(_ animated: Bool) {
        // 设置全局追踪
        arConfiguration.isLightEstimationEnabled = true
//        arSession.run(arConfiguration)
        arSession.run(arConfiguration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // 即将消失的时候暂停全局追踪
        arSession.pause()
    }
    
    
    // 初始化节点
    func initNode() {
        // 创建节点,确定节点几何
        sunNode.geometry = SCNSphere(radius: 3.0)
        earthNode.geometry = SCNSphere(radius: 1.0)
        moonNode.geometry = SCNSphere(radius: 0.5)
        
        // 对太阳节点进行渲染
        // multiply 镶嵌,把整张图片拉伸,之后会变淡
        sunNode.geometry?.firstMaterial?.multiply.contents = "art.scnassets/earth/sun.jpg"
        // diffuse:扩散,平均扩散到整个物体表面,并且光滑透亮
        sunNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/sun.jpg"
        sunNode.geometry?.firstMaterial?.multiply.intensity = 0.5
        sunNode.geometry?.firstMaterial?.lightingModel = .constant
        sunNode.geometry?.firstMaterial?.multiply.wrapS = .repeat
        sunNode.geometry?.firstMaterial?.diffuse.wrapS = .repeat
        sunNode.geometry?.firstMaterial?.multiply.wrapT = .repeat
        sunNode.geometry?.firstMaterial?.diffuse.wrapT = .repeat
        // 地球渲染
        earthNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/earth-diffuse-mini.jpg"
        // 添加地球的夜光图  emission :光热等的散发 specular:镜子的,会反射的
        earthNode.geometry?.firstMaterial?.emission.contents = "art.scnassets/earth/earth-emission-mini.jpg"
        earthNode.geometry?.firstMaterial?.specular.contents = "art.scnassets/earth/earth-specular-mini.jpg"
        // 月球进行渲染
        moonNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/moon.jpg"
        
        // 设置太阳的位置
        sunNode.position = SCNVector3(2, 0, -20)
        // 地月节点距离太阳为10
        earthGroupNode.position = SCNVector3(10, 0, 0)
        earthNode.position = SCNVector3(3, 0, 0)
        moonNode.position = SCNVector3(3, 0, 0)  // 这个地方有点不明白
        moonRotationNode.position = earthNode.position  // 重要:设置月球围绕地球转动的节点位置与地球的位置相同
        // 子节点的添加
        //4.让rootnode为sun sun上添加earth earth添加moon
        
//        sunNode.addChildNode(earthNode)
//
//        earthNode.addChildNode(moonNode)
        
        moonRotationNode.addChildNode(moonNode)
        earthGroupNode.addChildNode(moonRotationNode)
        earthGroupNode.addChildNode(earthNode)
        // 将节点添加到 scene 中
        // 少了一个这个,就看不见地月了
        sunNode.addChildNode(earthGroupNode)
        arSCNView.scene.rootNode.addChildNode(sunNode)
        
        
    }
    // 太阳自转
    func sunRotation() {
        // 旋转动画
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.duration = 10.0 // 旋转一周用的时间
        animation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Double.pi * 2)) // 不明白, 围绕自己的 y 轴转动
        animation.repeatCount = .greatestFiniteMagnitude // 最大值
        sunNode.addAnimation(animation, forKey: "sun-texture")
        
    }
    
    // MARK: - 设置地球的自转和月球围绕地球转
    // 月球如何围绕地球转呢?---  可以把月球放到地球上,让地球自转,月球就会跟着地球转,但是月球的转动周期和地球的自转周期是不一样的,所以创建一个月球围绕地球节点,(与地球节点位置相同,)让月球放到地月节点上,让这个节点自转,设置转动速度即可
    func earthTurn() {
        // 苹果有一套自带的动画,设置地球自转
        earthNode.runAction(.repeatForever(.rotateBy(x: 0, y: 2, z: 0, duration: 1)), forKey: "earth-texture")  // duration标识速度,数字越小,速度越快
        
        // 设置月球的自转
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.duration = 1.5
        animation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Double.pi * 2))// 围绕自己的 y 轴转动
        animation.repeatCount = .greatestFiniteMagnitude
        moonNode.addAnimation(animation, forKey: "moon-rotation")
        
        // 设置月球的公转
        let moonRotationAnimation = CABasicAnimation(keyPath: "rotation")
        moonRotationAnimation.duration = 10.0
        moonRotationAnimation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Double.pi * 2))
        moonRotationAnimation.repeatCount = .greatestFiniteMagnitude
        moonRotationNode.addAnimation(animation, forKey: "moon rotation around earth")
        
    }
    
    // 设置地球公转
    func earthRotation() {
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.duration = 10
        animation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Double.pi * 2))
        animation.repeatCount = .greatestFiniteMagnitude
        earthGroupNode.addAnimation(animation, forKey: "earth rotation around sun")
        
    }
    
    // MARK: - 设置太阳光晕和被光照到的地方
    func addLight() {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.color = UIColor.red // 被光照到的地方的颜色
        
        sunNode.addChildNode(lightNode)
        
        lightNode.light?.attenuationEndDistance = 20.0 //光照的亮度随着距离改变
        lightNode.light?.attenuationStartDistance = 1.0
        
        SCNTransaction.begin()
        
        
        SCNTransaction.animationDuration = 1
        
        
        
        lightNode.light?.color =  UIColor.white
        lightNode.opacity = 0.8 // make the halo stronger
        
        SCNTransaction.commit()
        
        sunHaloNode.geometry = SCNPlane.init(width: 25, height: 25)
        
        sunHaloNode.rotation = SCNVector4Make(1, 0, 0, Float(0 * Double.pi / 180.0))
        sunHaloNode.geometry?.firstMaterial?.diffuse.contents = "art.scnassets/earth/sun-halo.png"
        sunHaloNode.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant // no lighting
        sunHaloNode.geometry?.firstMaterial?.writesToDepthBuffer = false // 不要有厚度，看起来薄薄的一层
        sunHaloNode.opacity = 5
        
        sunHaloNode.addChildNode(sunHaloNode)
    }

}
