//
//  ReusableRoad.swift
//  PathFinder
//
//  Created by Nail Sharipov on 26.09.2021.
//

struct ReusableRoad {

    let id: Int
    var path: UnsafeArray<Int8>
    var length: Int
    var mask: RoadHash
    var movement: BitMatrix
    
    @inline(__always)
    var a: Int {
        mask.a
    }
    
    @inline(__always)
    var b: Int {
        mask.b
    }
    
    init(id: Int, count: Int) {
        self.id = id
        length = 0
        path = UnsafeArray<Int8>(capacity: count, repeating: 0)
        movement = BitMatrix(size: count)
        mask = RoadHash()
    }
    
    @inline(__always)
    func oposite(_ c: Int) -> Int {
        if c == a {
            return b
        } else {
            return a
        }
    }
    
    @inline(__always)
    mutating func prepare() {
        path.removeAll()
    }
    
    func dealocate() {
        path.dealocate()
        movement.deallocate()
    }
    
    @inline(__always)
    mutating func copyFrom(_ source: ReusableRoad) {
        length = source.length
        mask = source.mask
        movement.copyFrom(matrix: source.movement)
        path.replace(source.path.buffer, count: source.path.count)
    }
    
    @inline(__always)
    mutating func replacePath(road: ReusableRoad) {
        path.replace(road.path)
    }
    
    @inline(__always)
    mutating func appendPath(road: ReusableRoad, skip: Int = 0) {
        var i = skip
        repeat {
            path.append(road.path[i])
            i &+= 1
        } while i < road.path.count
    }

    @inline(__always)
    mutating func appendReversedPath(road: ReusableRoad, skip: Int = 0) {
        var i = road.path.count - 1 - skip
        repeat {
            path.append(road.path[i])
            i &-= 1
        } while i >= 0
    }
    
}

extension ReusableRoad: CustomStringConvertible {
    
    var description: String {
        return path.description
    }
}

extension ReusableRoad: CustomDebugStringConvertible {
    var debugDescription: String {
        self.description
    }
}
