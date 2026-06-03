//
// GameHUDView.swift
// LepreCON
//
// Compact gameplay status bar above the board.
//

import SwiftUI

struct GameHUDView: View {
    enum Style {
        /// Full chrome for previews or standalone use.
        case standalone
        /// Stats only; parent provides the top-bar frame and background.
        case embedded
    }

    let hud: GameHUDDisplay
    var style: Style = .standalone

    var body: some View {
        statsRow
            .frame(maxWidth: .infinity, alignment: statsAlignment)
            .modifier(HUDChromeModifier(style: style))
    }

    private var statsAlignment: Alignment {
        style == .embedded ? .center : .leading
    }

    private var statsRow: some View {
        HStack(spacing: style == .embedded ? 4 : 6) {
            HUDStatBadgeView(
                title: "Rainbow",
                value: "\(hud.rainbowCompleted)/\(hud.rainbowTotal)"
            )
            HUDStatBadgeView(title: "Bag", value: "\(hud.gemsInBag)")
            HUDStatBadgeView(
                title: "Gold",
                value: "\(hud.goldInPot)/\(hud.goldCapacity)"
            )
            HUDStatBadgeView(title: "Score", value: "\(hud.totalScore)")
        }
    }
}

private struct HUDChromeModifier: ViewModifier {
    let style: GameHUDView.Style

    func body(content: Content) -> some View {
        switch style {
        case .standalone:
            content
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(BoardStyle.hudPanelFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(BoardStyle.boardGoldOutline, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
        case .embedded:
            content
        }
    }
}

#Preview("Game HUD") {
    GameHUDView(
        hud: GameHUDDisplay(
            rainbowCompleted: 2,
            rainbowTotal: 6,
            gemsInBag: 82,
            goldInPot: 1,
            goldCapacity: 9,
            totalScore: 14
        )
    )
    .padding()
    .background(Color.green.opacity(0.2))
}
