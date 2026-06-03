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
    static let labelPlateFill = Color.black.opacity(0.42)
    static let labelPlateStroke = Color(red: 0.85, green: 0.68, blue: 0.22).opacity(0.65)

    static let hudPanelFill = Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.88)
    static let hudBadgeFill = Color.black.opacity(0.35)
    static let hudBadgeStroke = Color(red: 0.78, green: 0.62, blue: 0.18).opacity(0.55)
    static let hudTitle = Color.white.opacity(0.65)
    static let hudValue = Color(red: 0.98, green: 0.9, blue: 0.65)

    static var boardSkyGradient: [Color] {
        [
            Color(red: 0.35, green: 0.55, blue: 0.95).opacity(0.55),
            Color(red: 0.55, green: 0.35, blue: 0.85).opacity(0.45),
            Color(red: 0.2, green: 0.45, blue: 0.55).opacity(0.5),
            Color(red: 0.12, green: 0.28, blue: 0.38).opacity(0.65)
        ]
    }

    static var boardGoldOutline: Color {
        Color(red: 0.82, green: 0.65, blue: 0.2).opacity(0.75)
    }
}
