//
// CupScoringStatusView.swift
// LepreCON
//
// Simple scoring labels and buttons for one cup/lane (temporary UI).
//

import SwiftUI

struct CupScoringStatusView: View {
    let scoring: CupScoringDisplay
    let onConfirmScore: (GemKind) -> Void

    var body: some View {
        VStack(spacing: 3) {
            if let completed = scoring.completedCaption {
                Text(completed)
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.green)
                    .multilineTextAlignment(.center)
            }

            if let summary = scoring.pendingSummary {
                Text(summary)
                    .font(.caption2)
                    .foregroundStyle(.yellow)
                    .multilineTextAlignment(.center)
            }

            ForEach(scoring.pendingOptions) { option in
                Button("Score \(option.displayName)") {
                    onConfirmScore(option.scoringColor)
                }
                .font(.caption2)
                .buttonStyle(.borderedProminent)
                .controlSize(.mini)
            }
        }
    }
}
