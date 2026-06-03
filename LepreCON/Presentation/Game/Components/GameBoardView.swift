//
// GameBoardView.swift
// LepreCON
//
// Main visual gameplay board. Renders GameBoardDisplayState from the live session.
// Layout matches the rulebook image; domain cup indices are unchanged.
//

import SwiftUI

struct GameBoardView: View {
    let displayState: GameBoardDisplayState
    var onConfirmScore: ((Int, GemKind) -> Void)? = nil

    var body: some View {
        GeometryReader { geometry in
            let scale = BoardLayout.scale(for: geometry.size)
            let metrics = BoardLayoutMetrics(scale: scale)

            BoardContainerView {
                VStack(spacing: metrics.verticalSpacing) {
                    BoardLanesRowView(
                        lanes: displayState.rainbowLanes,
                        metrics: metrics,
                        onConfirmScore: onConfirmScore
                    )

                    BoardBottomRowView(
                        bottomRow: displayState.bottomRow,
                        metrics: metrics,
                        onConfirmScore: onConfirmScore
                    )
                }
            }
            .frame(width: BoardLayout.designWidth, height: BoardLayout.designHeight)
            .scaleEffect(scale)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
        .frame(minHeight: BoardLayout.designHeight * 0.82)
    }
}

#Preview("Game Board") {
    GameBoardView(displayState: GameBoardDisplayState.from(
        session: GameSessionFactory().makeNewGame(playerNames: ["Player 1"])
    ))
    .padding()
    .frame(height: 380)
}
