//
// SettingsMenuButton.swift
// LepreCON
//
// Game menu control using the settings asset when available.
//

import SwiftUI
import UIKit

private enum SettingsMenuAssets {
    static let imageName = "settings"
}

struct SettingsMenuButton<MenuContent: View>: View {
    var buttonSize: CGFloat = HUDBarArtLayout.topSettingsButtonSize
    @ViewBuilder let menuContent: () -> MenuContent

    var body: some View {
        Menu {
            menuContent()
        } label: {
            settingsLabel
                .frame(width: buttonSize, height: buttonSize)
                .accessibilityLabel("Game menu")
        }
    }

    @ViewBuilder
    private var settingsLabel: some View {
        if UIImage(named: SettingsMenuAssets.imageName) != nil {
            Image(SettingsMenuAssets.imageName)
                .resizable()
                .scaledToFit()
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        } else {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(BoardStyle.hudValue)
                .background(
                    Circle()
                        .fill(BoardStyle.hudBadgeFill.opacity(0.94))
                )
                .overlay(
                    Circle()
                        .stroke(BoardStyle.hudBadgeStroke, lineWidth: 0.75)
                )
        }
    }
}
