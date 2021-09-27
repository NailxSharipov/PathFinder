//
//  RoadSolution.swift
//  PathFinder
//
//  Created by Nail Sharipov on 26.09.2021.
//

public final class RoadSolution {
  
    private let matrix: UnsafeAdMatrix
    private let linkMatrix: LinkBitMatrix
    private var roadPool: RoadPool
    private var deletedCities: [Bool]
    private var citiesCount: Int
    private var max: Int = 0
    
    public struct Info {
        public let cities: [City]
    }
    
    public static func minPath(matrix: AdMatrix) -> [Int] {
        let solution = RoadSolution(matrix: matrix)
        let result = solution.solve()
        solution.dealocate()
        return result
    }
    
    private init(matrix adMatrix: AdMatrix) {
        self.matrix = UnsafeAdMatrix(matrix: adMatrix)
        self.linkMatrix = LinkBitMatrix(matrix: matrix)
        let n = adMatrix.size
        citiesCount = n
        self.deletedCities = [Bool](repeating: false, count: n)
        self.roadPool = RoadPool(initCapacity: n * n, count: n)
    }
    
    private func dealocate() {
        matrix.dealocate()
        linkMatrix.dealocate()
        roadPool.dealocate()
    }

    private func solve() -> [Int] {
        var cities = self.createCities()
        self.clearCities(cities: &cities)

        let count = linkMatrix.size

        var minPath = [Int8](repeating: 0, count: count)
        var minLength = Int.max
        
        let cityIndex = self.firstNotDeletedCitiyIndex()
        let city = cities[cityIndex]
        print("last step")
//        print(city.roadsDescription(roadPool: roadPool))

//        let allMask: UInt64 = ((1 << count) &- 1) - 0b11
        let allMask: UInt64 = ((1 << count) &- 1) - self.restCitiesMask()
        
        let n = city.roads.count
        
        var markBuffer = UnsafeList<RoadMark>(capacity: n)
        var j = 0
        while j < n {
            let roadId = city.roads[j]
            let road = roadPool[roadId]
            roadPool.addRemoved(id: roadId)
            let mark = RoadMark(road: road)
            markBuffer.append(mark)
            j &+= 1
        }
        
        var tempPath = UnsafeArray<Int8>(capacity: count)

        for i in 1..<n {
            let mark0 = markBuffer[i]
            let ab = roadPool[mark0.id]
            for j in 0..<i {
                let mark1 = markBuffer[j]
                if mark0.subMask & mark1.subMask == 0 && mark0.subMask | mark1.subMask == allMask {
                    let ba = roadPool[mark1.id]
                    
                    if ab.length + ba.length < minLength {
                        let pathLength = ab.length + ba.length
                        if ab.path.count == 2 {
                            ba.path.fill(buffer: &minPath)
                        } else if ba.path.count == 2 {
                            ab.path.fill(buffer: &minPath)
                        } else {
                            tempPath.replace(ab.path)
                            var i = ba.path.count - 2
                            while i != 0 {
                                tempPath.append(ba.path[i])
                                i &-= 1
                            }
                            tempPath.fill(buffer: &minPath)
                        }
                        minLength = pathLength
                    }
                }
            }
        }

        tempPath.dealocate()
        markBuffer.dealocate()
        
        for index in 0..<count {
            cities[index].dealocate()
        }
        
        cities.dealocate()

        return minPath.map({ Int($0) })
    }
    
    private func createCities() -> UnsafeList<ReusableCity> {
        let baseMovement = linkMatrix.base
        
        let count = linkMatrix.size

        var roadMap: [[Int]] = [[Int]](repeating: [], count: count)
        
        for b in 1..<count {
            var roads = [Int]()
            let b8 = Int8(b)
            for a in 0..<b {
                if !linkMatrix.isHord(a, b) {
                    if let roadBitMatrix = linkMatrix[a, b] {
                        let ab = matrix[a, b]
                        var road = roadPool.getFree()
                        baseMovement.intersect(map: roadBitMatrix, result: &road.movement)
                        road.length = ab
                        let a8 = Int8(a)
                        road.path.append(a8)
                        road.path.append(b8)
                        road.mask = RoadMask(a: a, b: b, subMask: 0)
                        roadPool[road.id] = road

                        roads.append(road.id)
                        
                        roadMap[a].append(road.id)
                    }
                }
            }
            roadMap[b].append(contentsOf: roads)
        }
        
        var cities = UnsafeList<ReusableCity>(capacity: count)
        
        for j in 0..<count {
            cities.append(ReusableCity(index: j, roads: roadMap[j]))
        }
        
        return cities
    }
    
    private func clearCities(cities: inout UnsafeList<ReusableCity>) {
        let count = linkMatrix.size
        
        var bestRoads = [RoadMask: ReusableRoad]()
        let capacity = count * count * count * count
        bestRoads.reserveCapacity(capacity)
        
        var markBuffer = UnsafeList<RoadMark>(capacity: capacity)
        
        var tempRoad = ReusableRoad(id: -1, count: count)
        
        var nextCityIndex = self.nextCity(cities: cities)
        
        var step = 0
        
        while nextCityIndex >= 0 {
            let city = cities[nextCityIndex]
            print("step: \(step), city: \(nextCityIndex)")
            print("roads count: \(city.roads.count)")
            step += 1
            markBuffer.removeAll()
            var j = 0
            while j < city.roads.count {
                let roadId = city.roads[j]
                let road = roadPool[roadId]
                roadPool.addRemoved(id: roadId)
                let mark = RoadMark(road: road)
                markBuffer.append(mark)
                j &+= 1
            }
            
            let n = markBuffer.count
            for i in 1..<n {
                let mark0 = markBuffer[i]
                for j in 0..<i {
                    let mark1 = markBuffer[j]
                    if (mark0.subMask & mark1.subMask == 0) && !mark0.isSameTarget(mark: mark1) {
                        if merge(mark0: mark0, mark1: mark1, newRoad: &tempRoad) {
                            if let prevBestRoad = bestRoads[tempRoad.mask] {
                                if prevBestRoad.length > tempRoad.length {
                                    let newRoad = roadPool.push(road: tempRoad)
                                    bestRoads[newRoad.mask] = newRoad
                                    roadPool.release(prevBestRoad.id)
                                }
                            } else {
                                let newRoad = roadPool.push(road: tempRoad)
                                bestRoads[newRoad.mask] = newRoad
                            }
                        }
                    }
                }
            }

            for index in 0..<city.roads.count {
                let roadId = city.roads[index]
                roadPool.release(roadId)
            }

            for i in 0..<count {
                var city = cities[i]
                city.clearRoads(roadPull: roadPool)
                cities[i] = city
            }
            
            roadPool.clearAllRemoved()
            
            for road in bestRoads.values {
                var aCity = cities[road.a]
                aCity.roads.append(road.id)
                cities[road.a] = aCity
                
                var bCity = cities[road.b]
                bCity.roads.append(road.id)
                cities[road.b] = bCity
            }
            
            bestRoads.removeAll(keepingCapacity: true)
            
            nextCityIndex = self.nextCity(cities: cities)
        }
        
        tempRoad.dealocate()
        
        markBuffer.dealocate()
    }
    
    // a < b always!
    
    @inline(__always)
    private func merge(mark0: RoadMark, mark1: RoadMark, newRoad: inout ReusableRoad) -> Bool {
        let road0 = self.roadPool[mark0.id]
        let road1 = self.roadPool[mark1.id]

        let abc = self.merge(road0: road0, road1: road1, newRoad: &newRoad)
        
        newRoad.movement.copyFrom(matrix: road0.movement)
        newRoad.movement.formIntersect(map: road1.movement)

        let subMask = mark0.subMask | mark1.subMask | (1 << abc.c)
        
        let count = road0.path.count &+ road1.path.count
        let length = road0.length &+ road1.length
        
        let factorCount = newRoad.movement.count - count + 1
        if factorCount > 0 {
            let visited = subMask.setBit(index: abc.a).setBit(index: abc.b)
            let factor = newRoad.movement.newConnectivityFactor(start: abc.a, end: abc.b, visited: visited, count: factorCount)
            if factor {
                newRoad.mask = RoadMask(a: abc.a, b: abc.b, subMask: subMask)
                newRoad.length = length
                return true
            }
            
            return false
        }

        newRoad.mask = RoadMask(a: abc.a, b: abc.b, subMask: subMask)
        newRoad.length = length
        return true
    }
    
    @inline(__always)
    private func merge(road0: ReusableRoad, road1: ReusableRoad, newRoad: inout ReusableRoad) -> (a: Int, b: Int, c: Int) {
        let a: Int
        let b: Int
        let c: Int
        
        let a0 = road0.a
        let b0 = road0.b
        
        let a1 = road1.a
        let b1 = road1.b
        
        newRoad.prepare()
        
        if a0 == a1 { // a0 == a1
            c = a0
            if b0 < b1 {
                // 0b-0a-1a-1b

                a = b0
                b = b1
                
                newRoad.appendReversedPath(road: road0)
                newRoad.appendPath(road: road1, skip: 1)
            } else {
                // 1b-1a-0a-0b

                a = b1
                b = b0

                newRoad.appendReversedPath(road: road1)
                newRoad.appendPath(road: road0, skip: 1)
            }
        } else if a0 == b1 { // a0 == b1
            // a1-b1-a0-b0

            c = a0
            a = a1
            b = b0
            
            newRoad.replacePath(road: road1)
            newRoad.appendPath(road: road0, skip: 1)
        } else if b0 == a1 {  // b0 == a1
            // a0-b0-a1-b1
            
            c = b0
            a = a0
            b = b1
            
            newRoad.replacePath(road: road0)
            newRoad.appendPath(road: road1, skip: 1)
        } else { // b0 == b1
            
            c = b0
            
            if a0 < a1 {
                // 0a-0b-1b-1a
                
                a = a0
                b = a1
            
                newRoad.replacePath(road: road0)
                newRoad.appendReversedPath(road: road1, skip: 1)
            } else {
                // 1a-1b-0b-0a
                b = a0
                a = a1
                
                newRoad.replacePath(road: road1)
                newRoad.appendReversedPath(road: road0, skip: 1)
            }
        }
        
        return (a: a, b: b, c: c)
    }
    
    private func nextCity(cities: UnsafeList<ReusableCity>) -> Int {
        guard citiesCount > 2 else {
            return -1
        }
        
        let n = cities.count
        var bestValue: Int = .max
        var bestIndex = -1
        for i in 0..<n where !deletedCities[i] {
            let city = cities[i]
            let count = city.roads.count
            if bestValue > count {
                bestValue = count
                bestIndex = i
            }
        }
        
        citiesCount -= 1
        deletedCities[bestIndex] = true
        return bestIndex
    }
    
    private func restCitiesMask() -> UInt64 {
        let n = self.deletedCities.count
        var mask: UInt64 = 0
        for i in 0..<n where !deletedCities[i] {
            mask = mask | (1 << i)
        }
        return mask
    }
    
    private func firstNotDeletedCitiyIndex() -> Int {
        let n = self.deletedCities.count
        for i in 0..<n where !deletedCities[i] {
            return i
        }
        return -1
    }
}
