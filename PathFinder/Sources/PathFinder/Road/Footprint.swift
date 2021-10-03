//
//  Footprint.swift
//  
//
//  Created by Nail Sharipov on 28.09.2021.
//

struct Footprint: Hashable {
    
    private let endMask: UInt64
    private let subMask: UInt64
    
    init(road0: ReusableRoad, road1: ReusableRoad) {
        endMask = (1 << road0.a) | (1 << road0.b) | (1 << road1.a) | (1 << road1.b)
        subMask = road0.mask.subMask | road0.mask.subMask
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(endMask)
        hasher.combine(subMask)
    }
}
