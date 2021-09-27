//
//  SceneLogic.swift
//  Shared
//
//  Created by Nail Sharipov on 23.09.2021.
//

import SwiftUI
import PathFinder

final class SceneLogic: ObservableObject {

    private (set) var pageIndex: Int
    private let key = String(describing: SceneLogic.self)
    private let data = SceneData.data
    private var moveIndex: Int?
    private var startPosition: CGPoint = .zero
    
    struct ViewModel {
        let dots: [DotView.Data]
        let path: [CGPoint]
    }
    
    @Published var points: [CGPoint] = []
    
    var viewModel: ViewModel {
        var dots = [DotView.Data]()
        dots.reserveCapacity(points.count)
        
        for p in points.enumerated() {
            let point = p.element
            dots.append(DotView.Data(index: p.offset, point: point, name: String(p.offset), color: .gray))
        }

        let indices = RoadSolution.minPath(matrix: AdMatrix(nodes: points))
        let path = indices.map({ points[$0] })

        return ViewModel(dots: dots, path: path)
    }
    
    init() {
//        self.pageIndex = 0
        self.pageIndex = UserDefaults.standard.integer(forKey: key)
        self.points = self.data[self.pageIndex].points
    }
    
    func onNext() {
        let n = self.data.count
        self.pageIndex = (self.pageIndex + 1) % n
        UserDefaults.standard.set(self.pageIndex, forKey: key)
        self.points = self.data[self.pageIndex].points
    }
    
    func onPrev() {
        let n = self.data.count
        self.pageIndex = (self.pageIndex - 1 + n) % n
        UserDefaults.standard.set(pageIndex, forKey: self.key)
        self.points = self.data[self.pageIndex].points
    }
    
}

extension SceneLogic: DragArea {
    
    func onStart(start: CGPoint, radius: CGFloat) -> Bool {
        let ox = start.x
        let oy = start.y
        self.moveIndex = nil
        var min = radius * radius
        for i in 0..<self.points.count {
            let p = self.points[i]
            let dx = p.x - ox
            let dy = p.y - oy
            let rr = dx * dx + dy * dy
            if rr < min {
                min = rr
                self.moveIndex = i
                self.startPosition = p
            }
        }

        return self.moveIndex != nil
    }
    
    func onMove(delta: CGSize) {
        guard let index = self.moveIndex else {
            return
        }
        let dx = delta.width
        let dy = delta.height
        self.points[index] = CGPoint(x: self.startPosition.x - dx, y: self.startPosition.y - dy)
    }
    
    func onEnd(delta: CGSize) {
        self.onMove(delta: delta)
    }
    
}
