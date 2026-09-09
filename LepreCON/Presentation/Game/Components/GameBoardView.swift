//
// GameBoardView.swift
// LepreCON
//
// Main visual gameplay board. Renders GameBoardDisplayState from the live session.
// Board content is drawn inside the fitted 390×540 canvas; extra playfield is margin.
//

import SwiftUI

struct GameBoardView: View {
    let displayState: GameBoardDisplayState
    var hideUnicornMarkers: Bool = false
    var discardCount: Int = 0
    var discardGemCounts: [GemCountDisplayItem] = []
    var isDiscardActiveDestination: Bool = false
    var isDiscardContentsPresented: Bool = false
    /// Playfield Y the tray bottom must stay at or above (dock top − board top − clearance).
    var discardTrayPlayfieldBottomLimit: CGFloat? = nil
    var onConfirmScore: ((Int, GemKind) -> Void)? = nil
    var onTapDiscardPile: () -> Void = {}
    var onDismissDiscardContents: () -> Void = {}

    var body: some View {
        GeometryReader { geometry in
            let metrics = BoardLayoutMetrics(playfieldSize: geometry.size)

            BoardContainerView {
                ZStack(alignment: .topLeading) {
                    // Letterbox / pillarbox margins stay empty outside the canvas.
                    Color.clear

                    boardCanvasContent(metrics: metrics)
                        .frame(
                            width: metrics.canvasFit.size.width,
                            height: metrics.canvasFit.size.height
                        )
                        .offset(
                            x: metrics.canvasFit.origin.x,
                            y: metrics.canvasFit.origin.y
                        )
                }
                .coordinateSpace(name: GameBoardCoordinateSpace.name)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .gameScreenDebugBorder(.green)
    }

    @ViewBuilder
    private func boardCanvasContent(metrics: BoardLayoutMetrics) -> some View {
        let kindCount = discardGemCounts.count
        let trayWidth = metrics.discardTrayWidth(gemKindCount: kindCount)
        let trayHeight = metrics.discardTrayHeight(
            gemKindCount: kindCount,
            panelWidth: trayWidth,
            playfieldBottomLimit: discardTrayPlayfieldBottomLimit
        )
        let trayBottomPadding = metrics.discardTrayBottomPadding(forHeight: trayHeight)
        let gridColumns = BoardLayoutMetrics.discardColumnCount(
            gemKindCount: kindCount,
            panelWidth: trayWidth,
            scale: metrics.canvasFit.scale
        )
        let maxTrayHeight = metrics.discardTrayMaxHeight(
            playfieldBottomLimit: discardTrayPlayfieldBottomLimit
        )
        let allowsScrolling = !BoardLayoutMetrics.discardGridFitsWithoutScrolling(
            gemKindCount: kindCount,
            panelWidth: trayWidth,
            maxHeight: maxTrayHeight,
            scale: metrics.canvasFit.scale
        )

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

            // Content-sized tray: opens downward below the stationary discard control.
            if isDiscardContentsPresented {
                DiscardPileContentsOverlay(
                    gemCounts: discardGemCounts,
                    discardCount: discardCount,
                    isActiveDestination: isDiscardActiveDestination,
                    panelWidth: trayWidth,
                    panelHeight: trayHeight,
                    gridColumnCount: max(gridColumns, 1),
                    allowsScrolling: allowsScrolling,
                    onDismiss: isDiscardActiveDestination ? nil : onDismissDiscardContents
                )
                .padding(.bottom, trayBottomPadding)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .zIndex(6)
            }
        }
        .frame(
            width: metrics.canvasWidth,
            height: metrics.canvasHeight,
            alignment: .bottom
        )
        // One shared composition shift — scales with canvasFit; does not retune pieces.
        .offset(y: metrics.contentVerticalOffset)
        .animation(.easeInOut(duration: 0.2), value: isDiscardContentsPresented)
    }
}

#Preview("Game Board") {
    GameBoardView(displayState: GameBoardDisplayState.from(
        session: GameSessionFactory().makeNewGame(playerNames: ["Player 1"])
    ))
    .padding()
    .frame(width: 390, height: 540)
}
