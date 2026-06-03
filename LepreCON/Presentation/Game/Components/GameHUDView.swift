//
// GameHUDView.swift
// LepreCON
//
// Compact gameplay status bar above the board.
//

import SwiftUI

struct GameHUDView: View {
    let hud: GameHUDDisplay

    var body: some View {
        VStack(spacing: 6) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    HUDStatBadgeView(title: "Turn", value: hud.turnLabel)
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

            Text(hud.compactSummaryLine)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(BoardStyle.hudTitle)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(BoardStyle.hudPanelFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(BoardStyle.boardGoldOutline, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
    }
}

#Preview("Game HUD") {
    GameHUDView(
        hud: GameHUDDisplay(
            turnLabel: "Turn",
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
