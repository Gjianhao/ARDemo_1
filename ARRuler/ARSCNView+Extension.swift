//
//  ARSCNView+Extension.swift
//  ARRuler
//
//  Created by gjh on 2017/12/5.
//  Copyright © 2017年 Gjianhao. All rights reserved.
//

import ARKit

extension ARSCNView {
    // 拿到三维坐标
    func worldVector(for position: CGPoint) -> SCNVector3? {
        // 在捕捉到的摄像机图像中搜索真实的物体或AR锚，对应于SceneKit视图中的一个点。
        // 通过AR会话对摄像机图像的处理，对真实世界的物体或表面进行测试。视图坐标系统中的一个2D点可以指向从设备摄像头开始的3D线上的任何点，并延伸到由设备定位和摄像机投影确定的方向。这个方法沿着这条线进行搜索，返回所有与摄像机相交的对象。
        // 该方法搜索AR会话所检测到的AR锚和实际对象，而不是视图中显示的场景内容。要搜索SceneKit对象，请使用视图的hitTest(:options:)方法。
        let results = hitTest(position, types: [.featurePoint])
        guard let result = results.first else { return nil }
        // 传入参数是:相对于世界坐标系统，碰撞测试结果的位置和方向。
        // 这个变换矩阵表示被检测到的表面和产生碰撞测试结果的射线的交点。一个hit test将图像或视图坐标系统中的2D点投射到3D世界空间中，并报告该线与探测到的表面相交的结果。
        return SCNVector3.positionTransform(result.worldTransform)
    }
}
