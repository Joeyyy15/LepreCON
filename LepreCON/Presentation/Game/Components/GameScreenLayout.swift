//
// GameScreenLayout.swift
// LepreCON
//
// Shared layout constants for the three-zone game screen (HUD, board, dock).
//

import SwiftUI

enum GameScreenLayout {
    /// Set true locally to outline HUD, board, and dock bounds.
    static let showLayoutDebug = false

    static let topBarHeight: CGFloat = 52
    static let hudToBoardGap: CGFloat = 4
    static let boardToDockGap: CGFloat = 4
    static let topPadding: CGFloat = 6
    static let bottomPadding: CGFloat = 4

    /// Inset from the safe-area edges to the shared foreground column (per side).
    static let horizontalInset: CGFloat = 20

    static let topBarInnerPadding: CGFloat = 10
    static let gearTrailingPadding: CGFloat = 10
    static let dockInnerPadding: CGFloat = 12
    static let dockSideSectionWidth: CGFloat = 80

    static let dockHeight: CGFloat = 120

    /// Width shared by HUD, board, and dock inside the safe visible area.
    static func contentWidth(in geometry: GeometryProxy) -> CGFloat {
        let safeWidth = geometry.size.width
            - geometry.safeAreaInsets.leading
            - geometry.safeAreaInsets.trailing
        return max(0, safeWidth - horizontalInset * 2)
    }

    static func topContentPadding(in geometry: GeometryProxy) -> CGFloat {
        topPadding + geometry.safeAreaInsets.top
    }

    static func bottomContentPadding(in geometry: GeometryProxy) -> CGFloat {
        bottomPadding + geometry.safeAreaInsets.bottom
    }
}

/// Centers HUD, board, and dock in one shared content column (width only, no extra horizontal padding).
struct GameScreenContentColumn<Content: View>: View {
    let geometry: GeometryProxy
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(width: GameScreenLayout.contentWidth(in: geometry))
            .frame(maxWidth: .infinity)
            .gameScreenDebugBorder(.cyan)
    }
}

private struct GameScreenDebugBorderModifier: ViewModifier {
    let enabled: Bool
    let color: Color

    func body(content: Content) -> some View {
        if enabled {
            content.border(color.opacity(0.85), width: 1)
        } else {
            content
        }
    }
}

extension View {
    func gameScreenDebugBorder(_ color: Color = .red) -> some View {
        modifier(GameScreenDebugBorderModifier(enabled: GameScreenLayout.showLayoutDebug, color: color))
    }
}
