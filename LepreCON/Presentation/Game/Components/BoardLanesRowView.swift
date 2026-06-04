//
// BoardLanesRowView.swift
// LepreCON
//
// Rainbow lane rows split for connected-board ZStack layering.
//

import SwiftUI

// MARK: - Lane backgrounds (behind clouds/pot)

struct BoardLaneBackgroundsRowView: View {
    let lanes: [RainbowLaneDisplay]
    let metrics: BoardLayoutMetrics

    var body: some View {
        HStack(alignment: .top, spacing: metrics.laneSpacing) {
            ForEach(lanes) { lane in
                RainbowLaneBackgroundView(
                    laneColor: lane.laneColor,
                    width: metrics.laneWidth,
                    height: metrics.laneHeight,
                    isHighlighted: lane.isHighlighted
                )
                .frame(
                    width: metrics.laneWidth,
                    height: metrics.laneHeight,
                    alignment: .top
                )
            }
        }
        .frame(width: metrics.playfieldWidth, alignment: .center)
    }
}

// MARK: - Lane gems + scoring (above clouds/pot)

struct BoardLaneGemsRowView: View {
    let lanes: [RainbowLaneDisplay]
    let metrics: BoardLayoutMetrics
    var onConfirmScore: ((Int, GemKind) -> Void)?

    var body: some View {
        HStack(alignment: .bottom, spacing: metrics.laneSpacing) {
            ForEach(lanes) { lane in
                laneGemsColumn(lane)
            }
        }
        .frame(width: metrics.playfieldWidth, alignment: .center)
    }

    @ViewBuilder
    private func laneGemsColumn(_ lane: RainbowLaneDisplay) -> some View {
        VStack(spacing: 4) {
            if lane.scoring.isCompleted || lane.scoring.hasPendingOptions {
                CupScoringStatusView(
                    scoring: lane.scoring,
                    onConfirmScore: { color in
                        onConfirmScore?(lane.cupIndex, color)
                    }
                )
                .frame(width: metrics.laneWidth)
            }

            ZStack(alignment: .topTrailing) {
                BoardLaneGemStack(
                    items: lane.gemCounts,
                    width: max(0, metrics.laneWidth - metrics.laneInnerPadding * 2),
                    height: metrics.laneGemStackHeight
                )
                .padding(.horizontal, metrics.laneInnerPadding)
                .frame(width: metrics.laneWidth, height: metrics.laneGemStackHeight, alignment: .bottom)

                if lane.hasUnicorn {
                    UnicornIndicatorView()
                        .padding(4)
                }
            }
            .frame(width: metrics.laneWidth, height: metrics.laneGemStackHeight)
        }
        .frame(width: metrics.laneWidth)
    }
}

// MARK: - Legacy combined row (previews / compatibility)

struct BoardLanesRowView: View {
    let lanes: [RainbowLaneDisplay]
    let metrics: BoardLayoutMetrics
    var onConfirmScore: ((Int, GemKind) -> Void)?

    var body: some View {
        HStack(alignment: .bottom, spacing: metrics.laneSpacing) {
            ForEach(lanes) { lane in
                laneColumn(lane)
            }
        }
        .frame(width: metrics.lanesRowWidth, alignment: .center)
    }

    @ViewBuilder
    private func laneColumn(_ lane: RainbowLaneDisplay) -> some View {
        VStack(spacing: 5) {
            RainbowLaneView(
                laneColor: lane.laneColor,
                gemCounts: lane.gemCounts,
                width: metrics.laneWidth,
                height: metrics.laneHeight,
                innerPadding: metrics.laneInnerPadding,
                isHighlighted: lane.isHighlighted,
                hasUnicorn: lane.hasUnicorn
            )

            if lane.scoring.isCompleted || lane.scoring.hasPendingOptions {
                CupScoringStatusView(
                    scoring: lane.scoring,
                    onConfirmScore: { color in
                        onConfirmScore?(lane.cupIndex, color)
                    }
                )
                .frame(width: metrics.laneWidth)
            }
        }
        .frame(width: metrics.laneWidth)
    }
}
