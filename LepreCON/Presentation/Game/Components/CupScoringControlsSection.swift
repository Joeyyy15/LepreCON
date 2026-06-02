//
// CupScoringControlsSection.swift
// LepreCON
//
// List of cups with pending score options below the board.
//

import SwiftUI

struct CupScoringControlsSection: View {
    let rows: [CupScoringRowDisplay]
    let onConfirmScore: (Int, GemKind) -> Void
    let onSkipScoring: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score a Cup")
                .font(.headline)

            Text("Score a cup below or choose Skip Scoring to continue.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(rows) { row in
                VStack(alignment: .leading, spacing: 6) {
                    Text(row.cupLabel)
                        .font(.subheadline.weight(.semibold))

                    HStack(spacing: 8) {
                        ForEach(row.pendingOptions) { option in
                            Button("Score \(option.displayName)") {
                                onConfirmScore(row.cupIndex, option.scoringColor)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                }
            }

            Button("Skip Scoring") {
                onSkipScoring()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
