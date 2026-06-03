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
            let designMetrics = BoardLayoutMetrics(scale: 1)
            let scaledSize = BoardLayout.scaledSize(for: geometry.size, scale: scale)
            let renderMetrics = BoardLayoutMetrics(scale: scale)

            BoardContainerView {
                VStack(spacing: designMetrics.verticalSpacing) {
                    BoardLanesRowView(
                        lanes: displayState.rainbowLanes,
                        metrics: renderMetrics,
                        onConfirmScore: onConfirmScore
                    )
                    .frame(maxWidth: designMetrics.playfieldWidth, alignment: .center)

                    BoardBottomRowView(
                        bottomRow: displayState.bottomRow,
                        metrics: renderMetrics,
                        onConfirmScore: onConfirmScore
                    )
                    .frame(maxWidth: designMetrics.playfieldWidth, alignment: .center)
                }
                .frame(width: designMetrics.playfieldWidth)
            }
            .frame(width: BoardLayout.designWidth, height: BoardLayout.designHeight)
            .scaleEffect(scale)
            .frame(width: scaledSize.width, height: scaledSize.height)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .gameScreenDebugBorder(.green)
    }
}

#Preview("Game Board") {
    GameBoardView(displayState: GameBoardDisplayState.from(
        session: GameSessionFactory().makeNewGame(playerNames: ["Player 1"])
    ))
    .padding()
    .frame(height: 380)
}
