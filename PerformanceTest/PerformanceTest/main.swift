//
//  main.swift
//  PerformanceTest
//
//  Created by Nail Sharipov on 26.09.2021.
//

import PathFinder
import Foundation

let data = Data.data[0]

let start = Date()
let path = RoadSolution.minPath(matrix: AdMatrix(nodes: data))
print(path)
let end = Date()

print(end.timeIntervalSince(start))
// 5.16
