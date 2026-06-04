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
            let metrics = BoardLayoutMetrics(playfieldSize: geometry.size)

            BoardContainerView {
                ZStack(alignment: .bottom) {
                    BoardLaneBackgroundsRowView(
                        lanes: displayState.rainbowLanes,
                        metrics: metrics
                    )
                    .padding(
                        .bottom,
                        metrics.bottomRowBottomInset + metrics.laneBackgroundBottomInset
                    )
                    .zIndex(0)

                    BoardBottomRowView(
                        bottomRow: displayState.bottomRow,
                        metrics: metrics,
                        onConfirmScore: onConfirmScore
                    )
                    .padding(.bottom, metrics.bottomRowBottomInset)
                    .zIndex(1)

                    BoardLaneGemsRowView(
                        lanes: displayState.rainbowLanes,
                        metrics: metrics,
                        onConfirmScore: onConfirmScore
                    )
                    .padding(
                        .bottom,
                        metrics.bottomRowBottomInset + metrics.laneGemStackBottomInset
                    )
                    .zIndex(2)
                }
                .frame(
                    width: metrics.playfieldWidth,
                    height: metrics.playfieldHeight,
                    alignment: .bottom
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .gameScreenDebugBorder(.green)
    }
}

#Preview("Game Board") {
    GameBoardView(displayState: GameBoardDisplayState.from(
        session: GameSessionFactory().makeNewGame(playerNames: ["Player 1"])
    ))
    .padding()
    .frame(width: 360, height: 420)
}
