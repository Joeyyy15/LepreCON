//
// BoardBottomRowView.swift
// LepreCON
//
// Bottom row inside the board: C2, C1, Pot, C4, C3 (display order from display state).
//

import SwiftUI

struct BoardBottomRowView: View {
    let bottomRow: [BottomRowSlotDisplay]
    let metrics: BoardLayoutMetrics
    var onConfirmScore: ((Int, GemKind) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: metrics.bottomSpacing) {
            ForEach(bottomRow) { slot in
                bottomSlotColumn(slot)
                    .frame(
                        width: slot.kind.isPot ? metrics.potWidth : metrics.cloudWidth,
                        alignment: .top
                    )
            }
        }
        .frame(width: metrics.playfieldWidth, alignment: .center)
    }

    @ViewBuilder
    private func bottomSlotColumn(_ slot: BottomRowSlotDisplay) -> some View {
        VStack(spacing: 4) {
            if slot.cupSlot.scoring.isCompleted || slot.cupSlot.scoring.hasPendingOptions {
                let labelWidth = slot.kind.isPot ? metrics.potWidth : metrics.cloudWidth
                CupScoringStatusView(
                    scoring: slot.cupSlot.scoring,
                    onConfirmScore: { color in
                        onConfirmScore?(slot.cupSlot.cupIndex, color)
                    }
                )
                .frame(width: labelWidth)
            }

            switch slot.kind {
            case .cloud(let number):
                CloudSlotView(
                    cloudNumber: number,
                    gemCounts: slot.cupSlot.gemCounts,
                    width: metrics.cloudWidth,
                    height: metrics.cloudHeight,
                    innerPadding: metrics.cupInnerPadding,
                    isHighlighted: slot.cupSlot.isHighlighted,
                    hasUnicorn: slot.cupSlot.hasUnicorn
                )
                .frame(
                    width: metrics.cloudWidth,
                    height: metrics.cloudHeight,
                    alignment: .top
                )
            case .pot:
                PotSlotView(
                    gemCounts: slot.cupSlot.gemCounts,
                    width: metrics.potWidth,
                    height: metrics.potHeight,
                    innerPadding: metrics.cupInnerPadding,
                    isHighlighted: slot.cupSlot.isHighlighted
                )
                .frame(
                    width: metrics.potWidth,
                    height: metrics.potHeight,
                    alignment: .top
                )
            }
        }
    }
}

private extension BottomRowSlotDisplay.Kind {
    var isPot: Bool {
        if case .pot = self { return true }
        return false
    }
}
