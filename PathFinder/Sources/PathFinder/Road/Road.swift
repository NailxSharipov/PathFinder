//
//  Road.swift
//  PathFinder
//
//  Created by Nail Sharipov on 26.09.2021.
//

public final class Road {
    
    public let path: [Int]
    public let length: Int
    public let mask: RoadMask
    let movement: BitMatrix
    var isRemoved: Bool = false
    
    @inline(__always)
    public var a: Int {
        mask.a
    }
    
    @inline(__always)
    public var b: Int {
        mask.b
    }
    
    @inline(__always)
    public var description: String? {
        let n = path.count
        guard n > 2 else { return nil }
        return path[1..<n - 1].map({ String($0) }).joined(separator: "-")
    }
    
    init(length: Int, path: [Int], movement: BitMatrix) {
        self.length = length
        self.path = path
        self.movement = movement
        self.mask = RoadMask(path: path)
    }
    
    deinit {
        self.movement.deallocate()
    }
    
    convenience init?(inRoad: Road, outRoad: Road) {
        let inMask = inRoad.mask
        let outMask = outRoad.mask
        guard inMask.subMask & outMask.subMask == 0, !(inMask.a == outMask.b && inMask.b == outMask.a) else {
            return nil
        }
        
        let newBMtx = inRoad.movement.intersect(map: outRoad.movement)

        let n = inRoad.path.count + outRoad.path.count - 1

        let length = inRoad.length &+ outRoad.length

        var path = [Int](repeating: 0, count: n)
        
        for i in 0..<inRoad.path.count {
            path[i] = inRoad.path[i]
        }
        var j = inRoad.path.count
        for i in 1..<outRoad.path.count {
            path[j] = outRoad.path[i]
            j &+= 1
        }

        let visited = UInt64(mask: path)
        
        let factor = newBMtx.connectivityFactor(start: outMask.b, visited: visited)
        let size = newBMtx.count
        let validFactor = size - n
        let isNotHorde = factor == validFactor

        guard isNotHorde else {
            newBMtx.deallocate()
            return nil
        }

        self.init(length: length, path: path, movement: newBMtx)
    }
    
}
