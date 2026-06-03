//
// HandPanelView.swift
// LepreCON
//
// Player hand gems, placement hint, and undo control.
//

import SwiftUI

struct HandPanelView: View {
    let handGemCounts: [GemCountDisplayItem]
    let emptyHandMessage: String
    let canPlaceFromHand: Bool
    let showsUndo: Bool
    let canUndoLastPlacement: Bool
    var onTapHandGemKind: (GemKind) -> Void = { _ in }
    var onUndoLastPlacement: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Hand")
                .font(.headline)

            if handGemCounts.isEmpty {
                Text(emptyHandMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                HandGemsView(
                    gemCounts: handGemCounts,
                    canPlace: canPlaceFromHand,
                    onTapKind: onTapHandGemKind
                )
            }

            if canPlaceFromHand {
                Text("Tap a gem type to place one into the highlighted cup")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if showsUndo {
                Button("Undo Last Placement", action: onUndoLastPlacement)
                    .buttonStyle(.bordered)
                    .disabled(!canUndoLastPlacement)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
