//
//  EdgeView.swift
//  Shared
//
//  Created by Nail Sharipov on 23.09.2021.
//

import SwiftUI

struct EdgeView: View {

    private let color: Color
    private let lineWidth: CGFloat
    private let points: [CGPoint]
    @ObservedObject private var state: DragAreaState

    struct Data {
        let index: Int
        let points: [CGPoint]
    }
    
    init(state: DragAreaState, points: [CGPoint], lineWidth: CGFloat = 3, color: Color = .gray) {
        self.state = state
        self.points = points
        self.lineWidth = lineWidth
        self.color = color
    }

    var body: some View {
        let screenPoints = state.screen(world: points)
        
        return ZStack {
            Path { path in
                path.addLines(screenPoints)
                path.closeSubpath()
            }.strokedPath(.init(lineWidth: lineWidth, lineCap: .round)).foregroundColor(color)
        }
    }
}
