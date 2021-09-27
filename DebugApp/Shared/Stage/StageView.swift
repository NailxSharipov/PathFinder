//
//  StageView.swift
//  Shared
//
//  Created by Nail Sharipov on 23.09.2021.
//

import SwiftUI

struct StageView: View {

    private let dragAreaState = DragAreaState()

    var body: some View {
        return GeometryReader { geometry in
            ZStack {
                СoordinateView(state: self.dragAreaState).background(Color.white)
                self.content(geometry: geometry).allowsHitTesting(false)
            }.gesture(MagnificationGesture()
                .onChanged { scale in
                    self.dragAreaState.modify(scale: scale)
                }
                .onEnded { scale in
                    self.dragAreaState.apply(scale: scale)
                }
            )
            .gesture(DragGesture()
                .onChanged { data in
                    self.dragAreaState.move(start: data.startLocation, current: data.location)
                }
                .onEnded { data in
                    self.dragAreaState.apply(start: data.startLocation, current: data.location)
                }
            )
        }
    }

    func content(geometry: GeometryProxy) -> some View {
        self.dragAreaState.sceneSize = geometry.size
        let logic = SceneLogic()
        self.dragAreaState.dragArea = logic
        return SceneView(state: self.dragAreaState, logic: logic)
    }
}
