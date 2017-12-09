//
//  SCNVector+Extension.swift
//  ARRuler
//
//  Created by gjh on 2017/12/5.
//  Copyright © 2017年 Gjianhao. All rights reserved.
//

import ARKit

extension SCNVector3 {
    // 跟相机的位置有关,拿到相机的实时位置
    static func positionTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    // 计算两点之间的距离
    func distance(from vector: SCNVector3) -> Float {
        let distanceX = self.x - vector.x
        let distanceY = self.y - vector.y
        let distanceZ = self.z - vector.z
        return sqrt((distanceX * distanceX) + (distanceY * distanceY) + (distanceZ * distanceZ))
    }
    
    // 画线的方法
    // SCNVector3 在macOS中，这个结构中的x、y和z字段是CGFloat值。在iOS、tvOS和watchOS中，这些字段都是浮动值。
    
    /// 根据结尾的点的位置,和颜色,画一条线
    ///
    /// - Parameters:
    ///   - vector: 点的位置
    ///   - color: 线的颜色
    /// - Returns: 返回一条线
    func line(to vector: SCNVector3, color: UIColor) -> SCNNode {
        let indices: [UInt32] = [0, 1] // 指数
        let source = SCNGeometrySource(vertices: [self, vector]) // 创建一个集合容器
        // 一个用来描述顶点连接定义一个三维物体或几何图形的索引数据的容器。
        let element = SCNGeometryElement(indices: indices, primitiveType: .line) // 创建一个几何元素
        let geometry = SCNGeometry(sources: [source], elements: [element]) // 通过一个容器和几何元素创建一个几何物件
        geometry.firstMaterial?.diffuse.contents = color // 进行渲染颜色
        let node = SCNNode(geometry: geometry) // 通过几何创建这个线的节点
        return node
    }
}

extension SCNVector3: Equatable {
    // 判断两个点的位置是否重合
    public static func == (lhs: SCNVector3, rhs:SCNVector3) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }
}
