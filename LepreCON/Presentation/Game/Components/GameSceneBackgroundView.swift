//
// GameSceneBackgroundView.swift
// LepreCON
//
// Full-screen fantasy meadow backdrop (gradients only; no image assets).
//

import SwiftUI

struct GameSceneBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.45, green: 0.72, blue: 0.98),
                    Color(red: 0.55, green: 0.82, blue: 0.95),
                    Color(red: 0.35, green: 0.62, blue: 0.88)
                ],
                startPoint: .top,
                endPoint: .center
            )

            LinearGradient(
                colors: [
                    Color.clear,
                    Color(red: 0.18, green: 0.52, blue: 0.28).opacity(0.55),
                    Color(red: 0.12, green: 0.42, blue: 0.22).opacity(0.85)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.92, blue: 0.55).opacity(0.22),
                    Color.clear
                ],
                center: .top,
                startRadius: 20,
                endRadius: 280
            )
        }
        .ignoresSafeArea()
    }
}

#Preview("Game Scene Background") {
    GameSceneBackgroundView()
}
