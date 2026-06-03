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
            let scaledSize = BoardLayout.scaledSize(for: geometry.size, scale: scale)
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
            .frame(width: scaledSize.width, height: scaledSize.height)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

#Preview("Game Board") {
    GameBoardView(displayState: GameBoardDisplayState.from(
        session: GameSessionFactory().makeNewGame(playerNames: ["Player 1"])
    ))
    .padding()
    .frame(height: 380)
}
