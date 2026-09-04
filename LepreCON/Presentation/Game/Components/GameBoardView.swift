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
    var hideUnicornMarkers: Bool = false
    var discardCount: Int = 0
    var discardGemCounts: [GemCountDisplayItem] = []
    var isDiscardActiveDestination: Bool = false
    var isDiscardContentsPresented: Bool = false
    var onConfirmScore: ((Int, GemKind) -> Void)? = nil
    var onTapDiscardPile: () -> Void = {}
    var onDismissDiscardContents: () -> Void = {}

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
                        hideUnicornMarkers: hideUnicornMarkers,
                        discardCount: discardCount,
                        isDiscardActiveDestination: isDiscardActiveDestination,
                        onConfirmScore: onConfirmScore,
                        onTapDiscardPile: onTapDiscardPile
                    )
                    .padding(.bottom, metrics.bottomRowBottomInset)
                    .zIndex(1)

                    BoardLaneGemsRowView(
                        lanes: displayState.rainbowLanes,
                        metrics: metrics,
                        hideUnicornMarkers: hideUnicornMarkers,
                        onConfirmScore: onConfirmScore
                    )
                    .padding(
                        .bottom,
                        metrics.bottomRowBottomInset + metrics.laneGemStackBottomInset
                    )
                    .zIndex(2)

                    // Overlay only — never participates in bottom-row / lane layout.
                    if isDiscardContentsPresented {
                        DiscardPileContentsOverlay(
                            gemCounts: discardGemCounts,
                            isActiveDestination: isDiscardActiveDestination,
                            panelWidth: metrics.discardOverlayWidth,
                            panelHeight: metrics.discardOverlayHeight,
                            onDismiss: isDiscardActiveDestination ? nil : onDismissDiscardContents
                        )
                        .padding(.bottom, metrics.discardOverlayBottomPadding)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .zIndex(6)
                    }
                }
                .frame(
                    width: metrics.playfieldWidth,
                    height: metrics.playfieldHeight,
                    alignment: .bottom
                )
                .animation(.easeInOut(duration: 0.2), value: isDiscardContentsPresented)
            }
            .coordinateSpace(name: GameBoardCoordinateSpace.name)
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
