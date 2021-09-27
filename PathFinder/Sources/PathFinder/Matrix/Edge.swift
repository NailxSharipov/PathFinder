//
//  Edge.swift
//  PathFinder
//
//  Created by Nail Sharipov on 26.09.2021.
//

public struct Edge: Hashable {
    public let a: Int
    public let b: Int
    
    init(a: Int, b: Int) {
        self.a = a
        self.b = b
    }
}


extension Edge: CustomStringConvertible {
    public var description: String {
        "\(a)-\(b)"
    }
}
