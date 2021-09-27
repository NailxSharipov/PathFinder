//
//  ReusableCity.swift
//  PathFinder
//
//  Created by Nail Sharipov on 26.09.2021.
//

struct ReusableCity {

    let index: Int
    var roads: UnsafeList<Int>
    
    init(index: Int, roads: [Int]) {
        self.index = index
        self.roads = UnsafeList<Int>(array: roads)
    }
    
    @inline(__always)
    mutating func clearRoads(roadPull: RoadPool) {
        var newRoads = UnsafeList<Int>(capacity: roads.capacity)
        for i in 0..<roads.count {
            let roadId = roads[i]
            if !roadPull.isRemoved(id: roadId) {
                newRoads.append(roadId)
            }
        }
        roads.dealocate()
        roads = newRoads
    }
    
    func dealocate() {
        roads.dealocate()
    }
    
    func roadsDescription(roadPool: RoadPool) -> String {
        var result = String()
        for i in 0..<roads.count {
            result.append(roadPool[roads[i]].path.description + "\n")
        }
        return result
    }
    
}
