//
// BoardStyle.swift
// LepreCON
//
// Shared visual constants for the gameplay board panel.
//

import SwiftUI

enum BoardStyle {
    static let cornerRadius: CGFloat = 20
    static let panelPadding: CGFloat = 12
    static let panelStrokeOpacity: Double = 0.5
    static let panelFillOpacity: Double = 0.14

    static let labelText = Color(red: 0.98, green: 0.92, blue: 0.72)
    static let labelPlateFill = Color.black.opacity(0.48)
    static let labelPlateStroke = Color(red: 0.85, green: 0.68, blue: 0.22).opacity(0.7)

    static let hudPanelFill = Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.88)
    static let hudBadgeFill = Color.black.opacity(0.35)
    static let hudBadgeStroke = Color(red: 0.78, green: 0.62, blue: 0.18).opacity(0.55)
    static let hudTitle = Color.white.opacity(0.65)
    static let hudValue = Color(red: 0.98, green: 0.9, blue: 0.65)

    static var boardGoldOutline: Color {
        Color(red: 0.82, green: 0.65, blue: 0.2).opacity(0.75)
    }

    /// Soft vignette behind the playfield — not a solid panel.
    static var boardSceneVignette: RadialGradient {
        RadialGradient(
            colors: [
                Color.black.opacity(0.16),
                Color.black.opacity(0.06),
                Color.clear
            ],
            center: .center,
            startRadius: 24,
            endRadius: 240
        )
    }

    /// Faint gold glow around the playfield for separation from the scene.
    static var boardPlayfieldGlow: Color {
        Color(red: 0.95, green: 0.82, blue: 0.35).opacity(0.22)
    }

    // Shared chrome for HUD and dock so the screen reads as one scene.
    static let sceneChromeRadius: CGFloat = 14
    static let dockPanelFill = Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.9)
    static let dockPanelStroke = Color(red: 0.82, green: 0.65, blue: 0.2).opacity(0.8)

    static var d12GradientTop: Color {
        Color(red: 1.0, green: 0.88, blue: 0.38)
    }

    static var d12GradientBottom: Color {
        Color(red: 0.88, green: 0.62, blue: 0.1)
    }
}
