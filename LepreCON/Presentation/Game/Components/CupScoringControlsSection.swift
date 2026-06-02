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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score a Cup")
                .font(.headline)

            Text("Choose which color to score. Matching the cup color scores more later.")
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
