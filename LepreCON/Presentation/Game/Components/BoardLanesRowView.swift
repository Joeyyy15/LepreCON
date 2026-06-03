//
// BoardLanesRowView.swift
// LepreCON
//
// Top row: six rainbow color lanes with optional scoring controls.
//

import SwiftUI

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
        .frame(maxWidth: .infinity)
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
