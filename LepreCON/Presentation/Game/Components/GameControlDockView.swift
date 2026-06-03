//
// GameControlDockView.swift
// LepreCON
//
// Three-section bottom dock: Undo (left), Roll D12 (center), Hand gems (right).
//

import SwiftUI

struct GameControlDockView: View {
    let handGemCounts: [GemCountDisplayItem]
    let currentRoll: Int?
    let showsRollControl: Bool
    let canRollD12: Bool
    let canPlaceFromHand: Bool
    let showsUndo: Bool
    let canUndo: Bool

    var onRollD12: () -> Void = {}
    var onUndo: () -> Void = {}
    var onTapHandGemKind: (GemKind) -> Void = { _ in }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            DockUndoButtonView(
                showsUndo: showsUndo,
                canUndo: canUndo,
                onUndo: onUndo
            )
            .frame(width: 76)

            DockD12RollView(
                showsRollControl: showsRollControl,
                canRollD12: canRollD12,
                currentRoll: currentRoll,
                onRollD12: onRollD12
            )
            .layoutPriority(1)

            DockHandGemsView(
                gemCounts: handGemCounts,
                canPlace: canPlaceFromHand,
                onTapKind: onTapHandGemKind
            )
            .frame(minWidth: 108, maxWidth: .infinity)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(height: GameScreenLayout.dockHeight)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: BoardStyle.sceneChromeRadius, style: .continuous)
                .fill(BoardStyle.dockPanelFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BoardStyle.sceneChromeRadius, style: .continuous)
                .stroke(BoardStyle.dockPanelStroke, lineWidth: 1.1)
        )
        .shadow(color: .black.opacity(0.24), radius: 5, x: 0, y: 2)
    }
}
