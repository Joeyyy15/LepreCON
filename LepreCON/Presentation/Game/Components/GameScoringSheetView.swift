//
// GameScoringSheetView.swift
// LepreCON
//
// Temporary sheet for cup scoring so the main dock stays compact.
//

import SwiftUI

struct GameScoringSheetView: View {
    let rows: [CupScoringRowDisplay]
    var onConfirmScore: (Int, GemKind) -> Void = { _, _ in }
    var onSkipScoring: () -> Void = {}

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                CupScoringControlsSection(
                    rows: rows,
                    onConfirmScore: onConfirmScore,
                    onSkipScoring: onSkipScoring
                )
                .padding()
            }
            .navigationTitle("Score a Cup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
