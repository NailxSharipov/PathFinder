//
//  SceneView.swift
//  Shared
//
//  Created by Nail Sharipov on 23.09.2021.
//

import SwiftUI

struct SceneView: View {

    @ObservedObject var logic: SceneLogic
    private let state: DragAreaState
    
    init(state: DragAreaState, logic: SceneLogic) {
        self.state = state
        self.logic = logic
    }
    
    var body: some View {
        let viewModel = self.logic.viewModel

        return ZStack {
            ForEach(viewModel.dots, id: \.index) { dot in
                DotView(
                    state: state,
                    point: dot.point,
                    name: dot.name,
                    color: Color.gray
                )
                EdgeView(
                    state: state,
                    points: viewModel.path
                )
            }
        }
    }
    
}

private extension Color {
    
    static let edge = Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 1)
    static let horde = Color(red: 1, green: 0, blue: 0, opacity: 0.1)
    static let step = Color(red: 0, green: 0, blue: 1.0, opacity: 0.4)
}
