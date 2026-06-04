//
// GameHUDView.swift
// LepreCON
//
// Compact gameplay status bar (standalone / preview).
//

import SwiftUI

struct GameHUDView: View {
    enum Style {
        case standalone
        case embedded
    }

    let hud: GameHUDDisplay
    var style: Style = .standalone

    var body: some View {
        Group {
            if style == .standalone {
                GameTopBarView(
                    hud: hud,
                    canStartGame: false,
                    canEndGame: false,
                    showsGameControls: false
                )
            } else {
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Game HUD") {
    GameHUDView(
        hud: GameHUDDisplay(
            rainbowCompleted: 0,
            rainbowTotal: 6,
            gemsInBag: 82,
            goldInPot: 1,
            goldCapacity: 9,
            totalScore: 0
        )
    )
    .frame(width: 360, height: GameScreenLayout.topBarHeight)
    .padding()
    .background(Color.green.opacity(0.2))
}
