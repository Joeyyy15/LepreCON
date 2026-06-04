//
// CupBoardAnchorPreference.swift
// LepreCON
//
// Reports cup centers and bounds in the gameplay board coordinate space for overlays.
//

import SwiftUI

enum GameBoardCoordinateSpace {
    static let name = "gameBoard"
}

/// Layout anchor for a board cup slot (center + frame in gameBoard space).
struct CupBoardAnchorInfo: Equatable {
    let center: CGPoint
    let bounds: CGRect
}

struct CupBoardAnchorKey: PreferenceKey {
    static var defaultValue: [Int: CupBoardAnchorInfo] = [:]

    static func reduce(value: inout [Int: CupBoardAnchorInfo], nextValue: () -> [Int: CupBoardAnchorInfo]) {
        value.merge(nextValue()) { _, new in new }
    }
}

extension View {
    /// Publishes this view's center and frame in the named game board coordinate space.
    func reportsCupBoardAnchor(cupIndex: Int) -> some View {
        background(
            GeometryReader { proxy in
                let frame = proxy.frame(in: .named(GameBoardCoordinateSpace.name))
                let info = CupBoardAnchorInfo(
                    center: CGPoint(x: frame.midX, y: frame.midY),
                    bounds: frame
                )
                Color.clear.preference(key: CupBoardAnchorKey.self, value: [cupIndex: info])
            }
        )
    }
}
