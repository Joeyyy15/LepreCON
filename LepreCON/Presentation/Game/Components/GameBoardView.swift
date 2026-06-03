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
            // This calculates how much the full board should scale
            // to fit inside the available middle screen area.
            let scale = BoardLayout.scale(for: geometry.size)

            // These metrics stay at the original design size.
            // The board should be built once at design size,
            // then scaled once using .scaleEffect(scale).
            let designMetrics = BoardLayoutMetrics(scale: 1)

            // This is the final visual size after the board is scaled.
            let scaledSize = BoardLayout.scaledSize(for: geometry.size, scale: scale)

            BoardContainerView {
                VStack(spacing: designMetrics.verticalSpacing) {
                    BoardLanesRowView(
                        lanes: displayState.rainbowLanes,
                        metrics: designMetrics,
                        onConfirmScore: onConfirmScore
                    )
                    .frame(width: designMetrics.playfieldWidth, alignment: .center)

                    BoardBottomRowView(
                        bottomRow: displayState.bottomRow,
                        metrics: designMetrics,
                        onConfirmScore: onConfirmScore
                    )
                    .frame(width: designMetrics.playfieldWidth, alignment: .center)
                }
                .frame(width: designMetrics.playfieldWidth, alignment: .center)
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
