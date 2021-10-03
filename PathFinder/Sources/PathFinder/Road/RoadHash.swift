//
//  RoadHash.swift
//  PathFinder
//
//  Created by Nail Sharipov on 26.09.2021.
//

public struct RoadHash: Hashable {
    
    let a: Int
    let b: Int
    let subMask: UInt64
    
    init() {
        a = 0
        b = 0
        subMask = 0
    }
    
    init(a: Int, b: Int, subMask: UInt64) {
        self.a = a
        self.b = b
        self.subMask = subMask
    }
    
    @inline(__always)
    init(path: [Int]) {
        let n = path.count
        var m: UInt64 = 0
        for i in 0..<n {
            let j = path[i]
            m = m | (1 << j)
        }
        self.a = path[0]
        self.b = path[n - 1]
        self.subMask = m.clearBit(index: a).clearBit(index: b)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(subMask)
    }

    @inline(__always)
    func opposite(_ c: Int) -> Int {
        if a == c {
            return b
        } else {
            return a
        }
    }
    
}
