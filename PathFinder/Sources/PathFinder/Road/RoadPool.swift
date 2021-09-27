//
//  ObjectPull.swift
//  PathFinder
//
//  Created by Nail Sharipov on 26.09.2021.
//


struct RoadPool {
    
    private var roads: UnsafeList<ReusableRoad>
    private var freeIndices: UnsafeList<Int>
    private var removedSet: UnsafeList<Bool>
    private var removedIds: UnsafeList<Int>
    private let count: Int
    
    init(initCapacity: Int, count: Int) {
        self.count = count
        self.roads = UnsafeList<ReusableRoad>(capacity: initCapacity)
        self.freeIndices = UnsafeList<Int>(capacity: initCapacity)
        self.removedSet = UnsafeList<Bool>(count: initCapacity, template: false)
        self.removedIds = UnsafeList<Int>(capacity: initCapacity)
        
        for i in 0..<initCapacity {
            let j = initCapacity - 1 - i
            freeIndices.append(j)
            roads.append(ReusableRoad(id: i, count: count))
        }
    }
    
    @inline(__always)
    func isRemoved(id: Int) -> Bool {
        removedSet[id]
    }

    @inline(__always)
    subscript(index: Int) -> ReusableRoad {
        get {
            roads[index]
        }
        set {
            roads[index] = newValue
        }
    }

    @inline(__always)
    mutating func getFree() -> ReusableRoad {
        var road: ReusableRoad
        if freeIndices.count == 0 {
            road = ReusableRoad(id: roads.count, count: count)
            roads.append(road)
            removedSet.append(false)
//            debugPrint(roads.count)
        } else {
            let id = freeIndices.removeLast()
            road = roads[id]
        }
        road.prepare()
        
        return road
    }
    
    @inline(__always)
    mutating func release(_ id: Int) {
        freeIndices.append(id)
    }

    @inline(__always)
    mutating func addRemoved(id: Int) {
        if !removedSet[id] {
            removedIds.append(id)
            removedSet[id] = true
        }
    }
    
    @inline(__always)
    mutating func clearAllRemoved() {
        for i in 0..<removedIds.count {
            let id = removedIds[i]
            removedSet[id] = false
        }
        removedIds.removeAll()
    }
    
    @inline(__always)
    mutating func push(road: ReusableRoad) -> ReusableRoad {
        var freeRoad = self.getFree()
        freeRoad.copyFrom(road)
        roads[freeRoad.id] = freeRoad
        return freeRoad
    }
    
    func dealocate() {
        for i in 0..<roads.count {
            roads[i].dealocate()
        }
        roads.dealocate()
        freeIndices.dealocate()
        removedSet.dealocate()
        removedIds.dealocate()
    }
}
