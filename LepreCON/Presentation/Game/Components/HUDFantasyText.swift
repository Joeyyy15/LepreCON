//
// HUDFantasyText.swift
// LepreCON
//
// Shared fantasy HUD typography for blank top_bar / bottom_bar overlays.
//

import SwiftUI

enum HUDFantasyText {
    static let labelFont = Font.system(size: 9, weight: .heavy, design: .rounded)
    static let valueFont = Font.system(size: 17, weight: .bold, design: .rounded)
    static let compactValueFont = Font.system(size: 15, weight: .bold, design: .rounded)
    static let sectionFont = Font.system(size: 10, weight: .heavy, design: .rounded)
    static let magicTitleFont = Font.system(size: 8, weight: .heavy, design: .rounded)
    static let magicSubtitleFont = Font.system(size: 8, weight: .bold, design: .rounded)
    static let rollCaptionFont = Font.system(size: 10, weight: .heavy, design: .rounded)

    static let labelColor = BoardStyle.hudTitle
    static let valueColor = BoardStyle.hudValue
}

struct HUDSectionLabel: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(HUDFantasyText.sectionFont)
            .foregroundStyle(HUDFantasyText.labelColor)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .shadow(color: .black.opacity(0.55), radius: 1.5, x: 0, y: 1)
    }
}

private struct HUDReadableShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.65), radius: 2, x: 0, y: 1)
            .shadow(color: Color(red: 0.45, green: 0.28, blue: 0.08).opacity(0.35), radius: 0.5, x: 0, y: 0)
    }
}

extension View {
    func hudReadableShadow() -> some View {
        modifier(HUDReadableShadow())
    }
}
