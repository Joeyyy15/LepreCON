//
// GameControlDockView.swift
// LepreCON
//
// Bottom dock: centered bottom_bar with anchored overlays.
//

import SwiftUI

struct GameControlDockView: View {
    let handGemCounts: [GemCountDisplayItem]
    let currentRoll: Int?
    let showsRollControl: Bool
    let canRollD12: Bool
    let canOpenHandTray: Bool
    let showsUndo: Bool
    let canUndo: Bool

    var onRollD12: () -> Void = {}
    var onUndo: () -> Void = {}
    var onOpenHandTray: () -> Void = {}

    var body: some View {
        GeometryReader { geometry in
            let barWidth = geometry.size.width
            let barHeight = geometry.size.height

            ZStack(alignment: .topLeading) {
                BottomBarArtBackground()

                HUDSectionLabel(text: "Undo")
                    .hudBarPosition(width: barWidth, height: barHeight, anchor: HUDBarArtLayout.dockUndoLabelAnchor)

                DockUndoButtonView(
                    showsUndo: showsUndo,
                    canUndo: canUndo,
                    compactOnArtBackground: true,
                    onUndo: onUndo
                )
                .hudBarPosition(width: barWidth, height: barHeight, anchor: HUDBarArtLayout.dockUndoIconAnchor)

                DockD12RollView(
                    showsRollControl: showsRollControl,
                    canRollD12: canRollD12,
                    currentRoll: currentRoll,
                    compactOnArtBackground: true,
                    onRollD12: onRollD12
                )
                .hudBarPosition(width: barWidth, height: barHeight, anchor: HUDBarArtLayout.dockRollDieAnchor)

                HUDSectionLabel(text: "Roll D12")
                    .hudBarPosition(width: barWidth, height: barHeight, anchor: HUDBarArtLayout.dockRollCaptionAnchor)

                HUDSectionLabel(text: "Hand")
                    .hudBarPosition(width: barWidth, height: barHeight, anchor: HUDBarArtLayout.dockHandLabelAnchor)

                DockHandPreviewView(
                    gemCounts: handGemCounts,
                    canOpenTray: canOpenHandTray,
                    onOpenTray: onOpenHandTray
                )
                .frame(maxWidth: barWidth * 0.34)
                .hudBarPosition(width: barWidth, height: barHeight, anchor: HUDBarArtLayout.dockHandContentAnchor)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gameScreenDebugBorder(.orange)
    }
}
