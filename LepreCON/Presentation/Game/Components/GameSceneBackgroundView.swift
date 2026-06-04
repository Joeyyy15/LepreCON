//
// GameSceneBackgroundView.swift
// LepreCON
//
// Full-screen fantasy backdrop behind HUD, board, and dock.
//

import SwiftUI

struct GameSceneBackgroundView: View {
    var body: some View {
        ZStack {
            fallbackGradient

            Image("game_background_fantasy")
                .resizable()
                .scaledToFill()

            readabilityOverlay
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    /// Visible if the image asset fails to load.
    private var fallbackGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.45, green: 0.72, blue: 0.98),
                Color(red: 0.35, green: 0.62, blue: 0.88),
                Color(red: 0.12, green: 0.42, blue: 0.22)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Light tint so HUD and dock text stay readable over the artwork.
    private var readabilityOverlay: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.1, blue: 0.22).opacity(0.12),
                Color(red: 0.04, green: 0.08, blue: 0.18).opacity(0.18),
                Color(red: 0.03, green: 0.12, blue: 0.14).opacity(0.22)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview("Game Scene Background") {
    GameSceneBackgroundView()
}
