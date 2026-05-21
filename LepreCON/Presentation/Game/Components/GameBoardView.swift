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

    /// Natural design size before scaling to fit the device.
    private static let designBoardWidth: CGFloat = 340
    private static let designBoardHeight: CGFloat = 360

    var body: some View {
        GeometryReader { geometry in
            let scale = boardScale(for: geometry.size)
            let metrics = BoardLayoutMetrics(scale: scale)

            ZStack {
                boardBackground

                VStack(spacing: metrics.verticalSpacing) {
                    rainbowLanes(metrics: metrics)
                    bottomRow(metrics: metrics)
                }
                .frame(width: Self.designBoardWidth, height: Self.designBoardHeight)
                .scaleEffect(scale)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            }
        }
        .frame(minHeight: Self.designBoardHeight * 0.85)
    }

    private func boardScale(for containerSize: CGSize) -> CGFloat {
        let widthScale = (containerSize.width - 8) / Self.designBoardWidth
        let heightScale = (containerSize.height - 8) / Self.designBoardHeight
        return min(widthScale, heightScale, 1.0)
    }

    private var boardBackground: some View {
        LinearGradient(
            colors: [
                .purple.opacity(0.35),
                .pink.opacity(0.25),
                .yellow.opacity(0.20),
                .cyan.opacity(0.25)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func rainbowLanes(metrics: BoardLayoutMetrics) -> some View {
        HStack(alignment: .bottom, spacing: metrics.laneSpacing) {
            ForEach(displayState.rainbowLanes) { lane in
                RainbowLaneView(
                    laneColor: lane.laneColor,
                    gemImageNames: lane.gemImageNames,
                    width: metrics.laneWidth,
                    height: metrics.laneHeight,
                    isHighlighted: lane.isHighlighted
                )
            }
        }
    }

    private func bottomRow(metrics: BoardLayoutMetrics) -> some View {
        HStack(alignment: .center, spacing: metrics.bottomSpacing) {
            ForEach(displayState.bottomRow) { slot in
                switch slot.kind {
                case .cloud(let number):
                    CloudSlotView(
                        cloudNumber: number,
                        gemImageNames: slot.cupSlot.gemImageNames,
                        width: metrics.cloudWidth,
                        height: metrics.cloudHeight,
                        isHighlighted: slot.cupSlot.isHighlighted
                    )
                case .pot:
                    PotSlotView(
                        gemImageNames: slot.cupSlot.gemImageNames,
                        width: metrics.potWidth,
                        height: metrics.potHeight,
                        isHighlighted: slot.cupSlot.isHighlighted
                    )
                }
            }
        }
    }
}

// MARK: - Responsive sizing

private struct BoardLayoutMetrics {
    let laneWidth: CGFloat
    let laneHeight: CGFloat
    let laneSpacing: CGFloat
    let cloudWidth: CGFloat
    let cloudHeight: CGFloat
    let potWidth: CGFloat
    let potHeight: CGFloat
    let bottomSpacing: CGFloat
    let verticalSpacing: CGFloat

    init(scale: CGFloat) {
        laneWidth = 42 * scale
        laneHeight = 260 * scale
        laneSpacing = 8 * scale
        cloudWidth = 68 * scale
        cloudHeight = 54 * scale
        potWidth = 88 * scale
        potHeight = 72 * scale
        bottomSpacing = 5 * scale
        verticalSpacing = 16 * scale
    }
}

#Preview("Game Board") {
    GameBoardView(displayState: GameBoardDisplayState.from(
        session: GameSessionFactory().makeNewGame(playerNames: ["Player 1"])
    ))
    .padding()
    .frame(height: 400)
}
