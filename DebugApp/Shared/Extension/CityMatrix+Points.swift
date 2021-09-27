//
//  CityMatrix+Points.swift
//  CityMatrix+Points
//
//  Created by Nail Sharipov on 01.08.2021.
//

import CoreGraphics
//import ShortestPath
//
//extension CityMatrix {
//    
//    static let defaultScale: CGFloat = 10000
//    
//    init(nodes: [CGPoint], scale: CGFloat = Self.defaultScale) {
//        let n = nodes.count
//        self.init(size: n)
//
//        for i in 1..<n {
//            for j in 0..<i {
//                let a = nodes[i]
//                let b = nodes[j]
//                let dx = a.x - b.x
//                let dy = a.y - b.y
//                let l = Int(((dx * dx + dy * dy).squareRoot() * scale).rounded(.toNearestOrAwayFromZero))
//
//                self[i, j] = l
//            }
//        }
//    }
//    
//    @inline(__always)
//    func scale(length: Int, scale: CGFloat = Self.defaultScale) -> CGFloat {
//        CGFloat(length) / scale
//    }
//    
//}
