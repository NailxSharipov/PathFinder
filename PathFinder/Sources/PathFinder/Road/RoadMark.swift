//
//  RoadMark.swift
//  PathFinder
//
//  Created by Nail Sharipov on 26.09.2021.
//

struct RoadMark {

    let id: Int
    let a: Int
    let b: Int
    let subMask: UInt64
    
    // a < b always!
    @inline(__always)
    func isSameTarget(mark: RoadMark) -> Bool {
        a == mark.a && b == mark.b
    }

    init(road: ReusableRoad) {
        self.id = road.id
        self.a = road.a
        self.b = road.b
        self.subMask = road.mask.subMask
    }
    
    
    
}
